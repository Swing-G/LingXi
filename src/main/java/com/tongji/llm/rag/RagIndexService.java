package com.tongji.llm.rag;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.tongji.knowpost.mapper.KnowPostMapper;
import com.tongji.knowpost.model.KnowPostDetailRow;
import com.tongji.config.EsProperties;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * RAG 绱㈠紩鏋勫缓鏈嶅姟锛? * - 灏嗗叕寮€涓斿凡鍙戝竷鐨勭煡鏂囧垏鐗囧苟鍐欏叆鍚戦噺搴? * - 閫氳繃鎸囩汗锛圫HA256/ETag锛夊垽鏂槸鍚﹂渶瑕侀噸寤猴紝淇濊瘉骞傜瓑
 * - 閲囩敤 delete-by-query 娓呯悊鏃у垏鐗囷紝鍐嶆壒閲?upsert 鏂板垏鐗? */
@Service
@RequiredArgsConstructor
public class RagIndexService {
    private static final Logger log = LoggerFactory.getLogger(RagIndexService.class);
    // 鍚戦噺搴撳皝瑁咃紙Elasticsearch VectorStore锛夛紝璐熻矗鍐欏叆/妫€绱㈠悜閲?    private final VectorStore vectorStore;
    // 鏁版嵁璁块棶锛氭牴鎹?postId 鏌ヨ鐭ユ枃璇︽儏锛堝惈 contentUrl銆佹寚绾圭瓑锛?    private final KnowPostMapper knowPostMapper;
    // 鎷夊彇 Markdown 姝ｆ枃鍐呭
    private final RestTemplate http = new RestTemplate();
    // 鐩存帴浣跨敤 ES 瀹㈡埛绔仛鎸囩汗鍒ゆ柇鍜屽垹闄ゆ棫鍒囩墖
    private final ElasticsearchClient es;
    // ES 鐩稿叧閰嶇疆锛堢储寮曞悕绛夛級
    private final EsProperties esProps;

    public void ensureIndexed(long postId) {
        reindexSinglePost(postId, true);
    }

    public int reindexSinglePost(long postId) {
        return reindexSinglePost(postId, false);
    }

    public int reindexSinglePost(long postId, boolean force) {
        KnowPostDetailRow row = knowPostMapper.findDetailById(postId);
        if (row == null) {
            log.warn("Post {} not found", postId);
            return 0;
        }

        // 浠呯储寮曞叕寮€鐨勫凡鍙戝竷鐭ユ枃
        if (!"published".equalsIgnoreCase(row.getStatus()) || !"public".equalsIgnoreCase(row.getVisible())) {
            log.warn("Post {} is not public/published, skip indexing", postId);
            return 0;
        }

        // 鍐呭鍦板潃缂哄け鍒欐棤娉曟姄鍙栨鏂?        if (!StringUtils.hasText(row.getContentUrl())) {
            log.warn("Post {} missing contentUrl or not found", postId);
            return 0;
        }

        // 鎸囩汗妫€娴嬶細濡傛湭鍙樺寲鍒欒烦杩囬噸寤猴紙force=true 鏃惰烦杩囨娴嬶級
        String currentSha = row.getContentSha256();
        String currentEtag = row.getContentEtag();
        if (!force && isUpToDate(postId, currentSha, currentEtag)) {
            log.info("Post {} already indexed with same fingerprint, skip (force={})", postId, force);
            return 0;
        }

        // 鎶撳彇 Markdown 姝ｆ枃
        String text = fetchContent(row.getContentUrl());
        if (!StringUtils.hasText(text)) {
            log.warn("Post {} content empty", postId);
            return 0;
        }

        // 鍏堟寜 Markdown 鏍囬鍒囨锛屽啀鍋氬浐瀹氶暱搴﹀垏鐗囷紙甯﹂噸鍙狅級
        List<String> chunks = chunkMarkdown(text);
        // 骞傜瓑 upsert锛氬厛鍒犻櫎鏃у垏鐗?        deleteExistingChunks(postId);

        // 缁勮 Document锛堟枃鏈?+ 涓氬姟鍏冩暟鎹級锛岀敤浜庡悜閲忓啓鍏ヤ笌妫€绱㈣繃婊?        List<Document> docs = new ArrayList<>(chunks.size());
        for (int i = 0; i < chunks.size(); i++) {
            String cid = postId + "#" + i;
            Map<String, Object> meta = new HashMap<>();
            meta.put("postId", String.valueOf(postId));
            meta.put("chunkId", cid);
            meta.put("position", i);
            meta.put("contentEtag", currentEtag);
            meta.put("contentSha256", currentSha);
            meta.put("contentUrl", row.getContentUrl());
            meta.put("title", row.getTitle());
            docs.add(new Document(chunks.get(i), meta));
        }
        try {
            // 鎵归噺鍐欏叆鍚戦噺搴?            vectorStore.add(docs);
            // 强制刷新 ES 索引，确保紧接着的搜索能查到刚写入的文档
            try {
                es.indices().refresh(r -> r.index(esProps.getIndex()));
            } catch (Exception e) {
                log.warn("ES refresh failed for post {}: {}", postId, e.getMessage());
            }
        } catch (Exception e) {
            log.error("VectorStore add failed: {}", e.getMessage());
            return 0;
        }
        // 杩斿洖鏈鍐欏叆鐨勫垏鐗囨暟閲?        return docs.size();
    }

    /**
     * 鎸囩汗鍒ゆ柇鏄惁闇€瑕侀噸寤猴細
     * - 浠?postId 鏌ヨ浠绘剰涓€鏉″凡绱㈠紩鏂囨。鐨?metadata
     * - 浼樺厛姣旇緝 SHA256锛屽叾娆℃瘮杈?ETag锛涗竴鑷村垯瑙嗕负鏃犻渶閲嶅缓
     */
    private boolean isUpToDate(long postId, String currentSha, String currentEtag) {
        try {
            if (!StringUtils.hasText(esProps.getIndex())) {
                // 鏈厤缃储寮曞悕鍒欐棤娉曞垽鏂紝鐩存帴瑙嗕负闇€瑕侀噸寤?                return false;
            }
            SearchResponse<Map> resp = es.search(s -> s
                            .index(esProps.getIndex())
                            .size(1)
                            .query(q -> q.term(t -> t
                                    .field("metadata.postId")
                                    .value(v -> v.stringValue(String.valueOf(postId))))),
                    Map.class);
            List<Hit<Map>> hits = resp.hits().hits();
            if (hits == null || hits.isEmpty()) return false;
            Map source = hits.getFirst().source();
            if (source == null) return false;
            Object metaObj = source.get("metadata");
            if (!(metaObj instanceof Map<?, ?> meta)) return false;
            String indexedSha = asString(meta.get("contentSha256"));
            String indexedEtag = asString(meta.get("contentEtag"));
            if (StringUtils.hasText(currentSha) && StringUtils.hasText(indexedSha)) {
                return Objects.equals(currentSha, indexedSha);
            }
            if (StringUtils.hasText(currentEtag) && StringUtils.hasText(indexedEtag)) {
                return Objects.equals(currentEtag, indexedEtag);
            }
            return false;
        } catch (Exception e) {
            log.warn("Fingerprint check failed for post {}: {}", postId, e.getMessage());
            return false;
        }
    }

    /**
     * 鍒犻櫎鏃у垏鐗囷細鎸?metadata.postId 绮剧‘鍒犻櫎锛岀‘淇?upsert 骞傜瓑
     */
    private void deleteExistingChunks(long postId) {
        try {
            if (!StringUtils.hasText(esProps.getIndex())) return;
            es.deleteByQuery(d -> d
                    .index(esProps.getIndex())
                    .query(q -> q.term(t -> t
                            .field("metadata.postId")
                            .value(v -> v.stringValue(String.valueOf(postId))))));
        } catch (Exception e) {
            log.warn("Delete old chunks failed for post {}: {}", postId, e.getMessage());
        }
    }

    private static String asString(Object o) {
        // 缁熶竴澶勭悊 null 鈫?String 鐨勮浆鎹?        return o == null ? null : String.valueOf(o);
    }

    /**
     * 鎷夊彇姝ｆ枃鍐呭锛岃嚜鍔ㄦ娴嬪瓧绗︾紪鐮侊紙UTF-8 / GB18030 鍥為€€锛夈€?     */
    private String fetchContent(String url) {
        if (url == null || url.isBlank()) return null;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setAccept(List.of(MediaType.TEXT_HTML, MediaType.TEXT_PLAIN, MediaType.APPLICATION_JSON));
            ResponseEntity<byte[]> resp = http.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), byte[].class);
            byte[] bytes = resp.getBody();
            if (bytes == null || bytes.length == 0) return null;

            MediaType contentType = resp.getHeaders().getContentType();
            Charset headerCharset = (contentType != null) ? contentType.getCharset() : null;
            Charset metaCharset = sniffHtmlCharset(bytes);
            Charset charset = pickCharset(bytes, headerCharset, metaCharset);
            return new String(bytes, charset);
        } catch (Exception e) {
            log.error("Fetch content failed: {}", e.getMessage());
            return null;
        }
    }

    private Charset pickCharset(byte[] bytes, Charset headerCharset, Charset metaCharset) {
        if (metaCharset != null) return metaCharset;
        if (headerCharset == null) {
            return countReplacement(new String(bytes, StandardCharsets.UTF_8))
                    <= countReplacement(new String(bytes, Charset.forName("GB18030")))
                    ? StandardCharsets.UTF_8 : Charset.forName("GB18030");
        }
        if (StandardCharsets.ISO_8859_1.equals(headerCharset) || StandardCharsets.US_ASCII.equals(headerCharset)) {
            int u = countReplacement(new String(bytes, StandardCharsets.UTF_8));
            int g = countReplacement(new String(bytes, Charset.forName("GB18030")));
            int h = countReplacement(new String(bytes, headerCharset));
            if (u <= g && u <= h) return StandardCharsets.UTF_8;
            if (g <= h) return Charset.forName("GB18030");
        }
        return headerCharset;
    }

    private Charset sniffHtmlCharset(byte[] bytes) {
        int limit = Math.min(bytes.length, 8192);
        String head = new String(bytes, 0, limit, StandardCharsets.ISO_8859_1);
        Matcher m = Pattern.compile("charset\\s*=\\s*['\\\"]?([a-zA-Z0-9_\\-]+)", Pattern.CASE_INSENSITIVE).matcher(head);
        if (!m.find()) return null;
        String cs = m.group(1);
        if (cs == null || cs.isBlank()) return null;
        cs = cs.trim();
        if ("utf8".equalsIgnoreCase(cs)) return StandardCharsets.UTF_8;
        if ("gbk".equalsIgnoreCase(cs) || "gb2312".equalsIgnoreCase(cs) || "gb18030".equalsIgnoreCase(cs))
            return Charset.forName("GB18030");
        try { return Charset.forName(cs); } catch (Exception e) { return null; }
    }

    private int countReplacement(String s) {
        if (s == null || s.isEmpty()) return 0;
        int cnt = 0;
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == '锟?) cnt++;
        }
        return cnt;
    }

    /**
     * 鎸?Markdown 鏍囬鍒囨锛屽啀浜ょ敱鍥哄畾闀垮害鍒囩墖绛栫暐澶勭悊銆?     */
    private List<String> chunkMarkdown(String text) {
        List<String> paras = new ArrayList<>();
        String[] lines = text.split("\r?\n");
        StringBuilder buf = new StringBuilder();
        for (String line : lines) {
            boolean isHeader = line.startsWith("#");
            if (isHeader && !buf.isEmpty()) { // 閬囧埌鏂扮殑鏍囬锛屾敹鏉熶笂涓€娈?                paras.add(buf.toString());
                buf.setLength(0);
            }
            buf.append(line).append('\n');
        }
        if (!buf.isEmpty()) paras.add(buf.toString());

        return getChunks(paras);
    }

    /**
     * 鍥哄畾闀垮害鍒囩墖锛堟瘡鐗?鈮?800 瀛楃锛夛紝鍒囩墖闂?100 瀛楃閲嶅彔锛?     * - 鍏奸【妫€绱㈠彫鍥炰笌涓婁笅鏂囪繛缁€?     */
    private static List<String> getChunks(List<String> paras) {
        List<String> chunks = new ArrayList<>();
        for (String p : paras) {
            if (p.length() <= 800) {
                chunks.add(p);
            } else {
                int start = 0;
                while (start < p.length()) {
                    int end = Math.min(start + 800, p.length());
                    chunks.add(p.substring(start, end));
                    if (end >= p.length()) break;
                    start = Math.max(end - 100, start + 1); // 閲嶅彔 100 瀛楃浠ヤ繚鐣欒涔夎繛缁?                }
            }
        }
        return chunks;
    }
}
