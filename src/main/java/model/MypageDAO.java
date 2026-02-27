package model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * MypageDAO.java - 프로필/마이페이지 통계 DB 접근 클래스
 *
 * kanji_log + kanji 테이블 기반 통계 조회
 * - getTotalStudiedCount()   : 학습한 한자 수 (중복 제외)
 * - getTotalKanjiCount()     : 전체 한자 수
 * - getAccuracyRate()        : 정답률 (%)
 * - getConsecutiveDays()     : 연속 학습 일수 (streak)
 * - getTodayStudyCount()     : 오늘 학습 문제 수
 * - getLevelStudiedCount()   : 레벨별 학습한 한자 수
 * - getLevelTotalCount()     : 레벨별 전체 한자 수
 */
public class MypageDAO {

    // ========== Oracle 접속 정보 ==========
    String url = "jdbc:oracle:thin:@localhost:1521:xe";
    String user = "member";
    String pass = "12345";

    Connection con;
    PreparedStatement pstmt;
    ResultSet rs;

    // ========== DB 연결 ==========
    public void getCon() {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== 학습한 한자 수 (중복 제외) ==========
    public int getTotalStudiedCount(int accID) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(DISTINCT kanjiID) AS cnt FROM kanji_log WHERE accID = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
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

    // ========== 전체 한자 수 ==========
    public int getTotalKanjiCount() {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(*) AS cnt FROM kanji";
            pstmt = con.prepareStatement(sql);
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

    // ========== 정답률 (%) ==========
    public int getAccuracyRate(int accID) {
        int rate = 0;
        try {
            getCon();
            String sql = "SELECT " +
                         "CASE WHEN COUNT(*) > 0 " +
                         "THEN ROUND(SUM(is_correct) * 100.0 / COUNT(*)) " +
                         "ELSE 0 END AS rate " +
                         "FROM kanji_log WHERE accID = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                rate = rs.getInt("rate");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rate;
    }

    // ========== 연속 학습 일수 (streak) ==========
    // 오늘 또는 어제부터 연속으로 학습한 날 수
    public int getConsecutiveDays(int accID) {
        int streak = 0;
        try {
            getCon();
            String sql = "SELECT DISTINCT TRUNC(studied_at) AS study_date " +
                         "FROM kanji_log WHERE accID = ? " +
                         "ORDER BY study_date DESC";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
            rs = pstmt.executeQuery();

            List<Long> dates = new ArrayList<>();
            while (rs.next()) {
                dates.add(rs.getDate("study_date").getTime());
            }
            con.close();

            if (dates.isEmpty()) return 0;

            // 오늘 자정 기준
            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            long today = cal.getTime().getTime();

            long oneDay = 24L * 60 * 60 * 1000;
            long latestStudy = dates.get(0);

            // 가장 최근 학습일이 오늘 또는 어제여야 streak 시작
            long gapFromToday = (today - latestStudy) / oneDay;
            if (gapFromToday > 1) return 0;

            streak = 1;
            for (int i = 1; i < dates.size(); i++) {
                long diff = (dates.get(i - 1) - dates.get(i)) / oneDay;
                if (diff == 1) {
                    streak++;
                } else {
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return streak;
    }

    // ========== 오늘 학습 문제 수 ==========
    public int getTodayStudyCount(int accID) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(*) AS cnt FROM kanji_log " +
                         "WHERE accID = ? AND TRUNC(studied_at) = TRUNC(SYSDATE)";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, accID);
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

    // ========== 레벨별 학습한 한자 수 (JOIN) ==========
    public int getLevelStudiedCount(int accID, String level) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(DISTINCT kl.kanjiID) AS cnt " +
                         "FROM kanji_log kl " +
                         "JOIN kanji k ON kl.kanjiID = k.kanjiID " +
                         "WHERE kl.accID = ? AND k.jlpt_level = ?";
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

    // ========== 레벨별 전체 한자 수 ==========
    public int getLevelTotalCount(String level) {
        int count = 0;
        try {
            getCon();
            String sql = "SELECT COUNT(*) AS cnt FROM kanji WHERE jlpt_level = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, level);
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
}
