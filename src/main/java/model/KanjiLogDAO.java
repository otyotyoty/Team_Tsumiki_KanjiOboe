package model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class KanjiLogDAO {

    String url = "jdbc:oracle:thin:@localhost:1521:xe";
    String user = "member";
    String pass = "12345";

    Connection con;
    PreparedStatement pstmt;
    ResultSet rs;

    public void getCon() {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== 학습 로그 INSERT (기본 3파라미터) ==========
    public void insertLog(int accID, int kanjiID, int isCorrect) {
        try {
            getCon();
            String sql = "INSERT INTO kanji_log (accID, kanjiID, is_correct) VALUES (?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, kanjiID);
            pstmt.setInt(3, isCorrect);
            pstmt.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== 학습 로그 INSERT (level, sector 포함 5파라미터) ==========
    public void insertLog(int accID, int kanjiID, int isCorrect, String level, int sector) {
        try {
            getCon();
            String sql = "INSERT INTO kanji_log (accID, kanjiID, is_correct, jlpt_level, sector) VALUES (?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, kanjiID);
            pstmt.setInt(3, isCorrect);
            pstmt.setString(4, level);
            pstmt.setInt(5, sector);
            pstmt.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== 오답 기록 삭제 (복습 테스트에서 맞추면 호출) ==========
    public void deleteWrongLogs(int accID, int kanjiID) {
        try {
            getCon();
            String sql = "DELETE FROM kanji_log WHERE accID = ? AND kanjiID = ? AND is_correct = 0";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, kanjiID);
            pstmt.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== 해당 월 출석 날짜 목록 (캘린더용) ==========
    public List<Integer> getMonthAttendance(int accID, int year, int month) {
        List<Integer> days = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT DISTINCT EXTRACT(DAY FROM studied_at) AS day " +
                         "FROM kanji_log WHERE accID = ? " +
                         "AND EXTRACT(YEAR FROM studied_at) = ? " +
                         "AND EXTRACT(MONTH FROM studied_at) = ? ORDER BY day";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, year);
            pstmt.setInt(3, month);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                days.add(rs.getInt("day"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return days;
    }

    // ========== 오늘 출석 여부 확인 ==========
    public boolean isTodayAttended(int accID) {
        boolean attended = false;
        try {
            getCon();
            String sql = "SELECT COUNT(*) AS cnt FROM kanji_log " +
                         "WHERE accID = ? AND TRUNC(studied_at) = TRUNC(SYSDATE)";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                attended = rs.getInt("cnt") > 0;
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return attended;
    }

    // ========== 해당 월 출석 일수 ==========
    public int getMonthAttendCount(int accID, int year, int month) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(DISTINCT TRUNC(studied_at)) AS attend_days " +
                         "FROM kanji_log WHERE accID = ? " +
                         "AND EXTRACT(YEAR FROM studied_at) = ? " +
                         "AND EXTRACT(MONTH FROM studied_at) = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, year);
            pstmt.setInt(3, month);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt("attend_days");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // ========== 전체 오답 한자 ID 목록 ==========
    public List<Integer> getWrongKanjiIDs(int accID) {
        List<Integer> kanjiIDs = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT DISTINCT kanjiID FROM kanji_log " +
                         "WHERE accID = ? AND is_correct = 0 ORDER BY kanjiID";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                kanjiIDs.add(rs.getInt("kanjiID"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kanjiIDs;
    }

    // ========== 레벨별 오답 한자 ID 목록 ==========
    public List<Integer> getWrongKanjiIDsByLevel(int accID, String level) {
        List<Integer> kanjiIDs = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT DISTINCT kl.kanjiID FROM kanji_log kl " +
                         "JOIN kanji k ON kl.kanjiID = k.kanjiID " +
                         "WHERE kl.accID = ? AND kl.is_correct = 0 AND k.jlpt_level = ? " +
                         "ORDER BY kl.kanjiID";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setString(2, level);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                kanjiIDs.add(rs.getInt("kanjiID"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kanjiIDs;
    }

    // ========== 레벨+섹터별 오답 한자 ID 목록 ==========
    public List<Integer> getWrongKanjiIDsByLevelSector(int accID, String level, int sector) {
        List<Integer> kanjiIDs = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT DISTINCT kl.kanjiID FROM kanji_log kl " +
                         "JOIN kanji k ON kl.kanjiID = k.kanjiID " +
                         "WHERE kl.accID = ? AND kl.is_correct = 0 " +
                         "AND k.jlpt_level = ? AND k.sector = ? ORDER BY kl.kanjiID";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setString(2, level);
            pstmt.setInt(3, sector);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                kanjiIDs.add(rs.getInt("kanjiID"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kanjiIDs;
    }

    // ========== 레벨별 오답 한자 수 ==========
    public int getWrongKanjiCountByLevel(int accID, String level) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(DISTINCT kl.kanjiID) AS cnt FROM kanji_log kl " +
                         "JOIN kanji k ON kl.kanjiID = k.kanjiID " +
                         "WHERE kl.accID = ? AND kl.is_correct = 0 AND k.jlpt_level = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setString(2, level);
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

    // ========== 레벨+섹터별 오답 한자 수 ==========
    public int getWrongKanjiCountByLevelSector(int accID, String level, int sector) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(DISTINCT kl.kanjiID) AS cnt FROM kanji_log kl " +
                         "JOIN kanji k ON kl.kanjiID = k.kanjiID " +
                         "WHERE kl.accID = ? AND kl.is_correct = 0 " +
                         "AND k.jlpt_level = ? AND k.sector = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setString(2, level);
            pstmt.setInt(3, sector);
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

    // ========== 특정 한자의 정답/오답 횟수 ==========
    public int[] getKanjiScore(int accID, int kanjiID) {
        int[] score = {0, 0};
        try {
            getCon();
            String sql = "SELECT is_correct, COUNT(*) AS cnt FROM kanji_log " +
                         "WHERE accID = ? AND kanjiID = ? GROUP BY is_correct";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            pstmt.setInt(2, kanjiID);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int isCorrect = rs.getInt("is_correct");
                int cnt = rs.getInt("cnt");
                if (isCorrect == 1) score[0] = cnt;
                else score[1] = cnt;
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return score;
    }
    
 // ========== 학습한 한자 ID 목록 (정답/오답 무관, 중복 제외) ==========
    public List<Integer> getStudiedKanjiIDs(int accID) {
        List<Integer> kanjiIDs = new ArrayList<>();
        try {
            getCon();
            String sql = "SELECT DISTINCT kanjiID FROM kanji_log WHERE accID = ? ORDER BY kanjiID";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                kanjiIDs.add(rs.getInt("kanjiID"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kanjiIDs;
    }
}