package model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * KanjiDAO.java - 한자 DB 접근 클래스
 * 
 * kanji 테이블 기준
 * - findByLevel()            : 해당 레벨 전체 한자 목록
 * - findBySector()           : 해당 레벨+섹터 한자 목록 (= getKanjiByLevelSector)
 * - findByKanjiID()          : kanjiID로 한자 1개 조회
 * - findByKanjiindex()       : kanjiindex로 한자 1개 조회
 * - countByLevel()           : 해당 레벨 한자 개수
 * - countBySector()          : 해당 레벨+섹터 한자 개수
 * - getMaxSector()           : 해당 레벨 최대 섹터 번호
 * - getKanjiByLevelSector()  : findBySector 별칭 (JSP에서 호출)
 * - getKanjiID()             : 한자문자+레벨+섹터로 kanjiID 조회 (테스트 결과 저장용)
 */
public class KanjiDAO {

    // ========== Oracle 접속 정보 ==========
    // ★ SQL Developer 접속 정보와 동일하게 맞추세요
    // ★ 왼쪽 패널의 접속명이 MD_SYSTEM이면 아래 정보 확인 필요
    String url = "jdbc:oracle:thin:@localhost:1521:xe";
    String user = "member";   // ← SQL Developer에서 사용하는 계정
    String pass = "12345";    // ← 해당 계정의 비밀번호

    Connection con;
    PreparedStatement pstmt;
    ResultSet rs;

    // ========== 마지막 에러 메시지 (디버깅용) ==========
    public String lastError = "";

    // ========== DB 연결 ==========
    public void getCon() {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            lastError = "getCon 에러: " + e.getMessage();
            e.printStackTrace();
        }
    }

    // ========== ResultSet → KanjiDTO 변환 (공통) ==========
    private KanjiDTO rsToDTO(ResultSet rs) throws Exception {
        KanjiDTO dto = new KanjiDTO();
        dto.setKanjiID(rs.getInt("kanjiID"));
        dto.setKanjiindex(rs.getString("kanjiindex"));
        dto.setKanji(rs.getString("kanji"));
        dto.setOnyomi1(rs.getString("onyomi1"));
        dto.setOnyomi2(rs.getString("onyomi2"));
        dto.setOnyomi3(rs.getString("onyomi3"));
        dto.setKunyomi1(rs.getString("kunyomi1"));
        dto.setKunyomi2(rs.getString("kunyomi2"));
        dto.setKunyomi3(rs.getString("kunyomi3"));
        dto.setKoreanMeaning(rs.getString("korean_meaning"));
        dto.setMeaningDescription(rs.getString("meaning_description"));
        dto.setExample1(rs.getString("example1"));
        dto.setExample2(rs.getString("example2"));
        dto.setExample3(rs.getString("example3"));
        dto.setJlptLevel(rs.getString("jlpt_level"));
        dto.setSector(rs.getInt("sector"));
        dto.setIndexNum(rs.getInt("index_num"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        return dto;
    }

    // ========== 해당 레벨 전체 한자 목록 ==========
    public List<KanjiDTO> findByLevel(String jlptLevel) {
        List<KanjiDTO> list = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT * FROM kanji WHERE jlpt_level = ? ORDER BY sector, index_num";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, jlptLevel);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rsToDTO(rs));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== 해당 레벨+섹터 한자 목록 ==========
    public List<KanjiDTO> findBySector(String jlptLevel, int sector) {
        List<KanjiDTO> list = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT * FROM kanji WHERE jlpt_level = ? AND sector = ? ORDER BY index_num";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, jlptLevel);
            pstmt.setInt(2, sector);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rsToDTO(rs));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== JSP에서 호출하는 별칭 메서드 ==========
    // findBySector와 동일 기능
    public List<KanjiDTO> getKanjiByLevelSector(String jlptLevel, int sector) {
        return findBySector(jlptLevel, sector);
    }

    // ========== kanjiID로 한자 1개 조회 ==========
    public KanjiDTO findByKanjiID(int kanjiID) {
        KanjiDTO dto = null;
        try {
            getCon();
            String sql = "SELECT * FROM kanji WHERE kanjiID = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, kanjiID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = rsToDTO(rs);
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }

    // ========== kanjiindex로 한자 1개 조회 ==========
    public KanjiDTO findByKanjiindex(String kanjiindex) {
        KanjiDTO dto = null;
        try {
            getCon();
            String sql = "SELECT * FROM kanji WHERE kanjiindex = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, kanjiindex);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = rsToDTO(rs);
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }

    // ========== 한자문자 + 레벨 + 섹터로 kanjiID 조회 ==========
    // 테스트 결과 저장 시 사용 (kanji_log INSERT에 kanjiID 필요)
    public int getKanjiID(String kanjiChar, String jlptLevel, int sector) {
        int kanjiID = -1;
        try {
            getCon();
            String sql = "SELECT kanjiID FROM kanji WHERE kanji = ? AND jlpt_level = ? AND sector = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, kanjiChar);
            pstmt.setString(2, jlptLevel);
            pstmt.setInt(3, sector);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                kanjiID = rs.getInt("kanjiID");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kanjiID;
    }

    // ========== 해당 레벨 한자 개수 ==========
    public int countByLevel(String jlptLevel) {
        int count = 0;
        try {
            getCon();
            if (con == null) {
                lastError += " / countByLevel: con is null";
                return 0;
            }
            String sql = "SELECT COUNT(*) AS cnt FROM kanji WHERE jlpt_level = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, jlptLevel);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt("cnt");
            }
            con.close();
        } catch (Exception e) {
            lastError += " / countByLevel 에러: " + e.getMessage();
            e.printStackTrace();
        }
        return count;
    }

    // ========== 해당 레벨+섹터 한자 개수 ==========
    public int countBySector(String jlptLevel, int sector) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(*) AS cnt FROM kanji WHERE jlpt_level = ? AND sector = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, jlptLevel);
            pstmt.setInt(2, sector);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt("cnt");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // ========== 해당 레벨 최대 섹터 번호 ==========
    public int getMaxSector(String jlptLevel) {
        int maxSector = 0;
        try {
            getCon();
            String sql = "SELECT NVL(MAX(sector), 0) AS max_sector FROM kanji WHERE jlpt_level = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, jlptLevel);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                maxSector = rs.getInt("max_sector");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return maxSector;
    }
}