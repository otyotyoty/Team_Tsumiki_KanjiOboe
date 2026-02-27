package model;

import java.sql.Timestamp;

/**
 * KanjiLogDTO.java - 학습 로그 정보 담는 클래스
 * 
 * DB kanji_log 테이블 매핑:
 * - logID      : PK (NUMBER, 자동생성)
 * - accID      : 회원 PK (account.accID FK)
 * - kanjiID    : 한자 PK (kanji.kanjiID FK)
 * - is_correct : 정답 여부 (0=오답, 1=정답)
 * - studied_at : 학습 시각 (TIMESTAMP, DEFAULT SYSTIMESTAMP)
 * 
 * ★ 출석 판단: 해당 날짜에 kanji_log 기록이 1개라도 있으면 출석 O
 */
public class KanjiLogDTO {

    private int logID;          // PK (자동생성)
    private int accID;          // 회원 PK (FK)
    private int kanjiID;        // 한자 PK (FK)
    private int isCorrect;      // 정답 여부 (0 또는 1)
    private Timestamp studiedAt; // 학습 시각

    // ========== 기본 생성자 ==========
    public KanjiLogDTO() {}

    // ========== Getter / Setter ==========

    public int getLogID() { return logID; }
    public void setLogID(int logID) { this.logID = logID; }

    public int getAccID() { return accID; }
    public void setAccID(int accID) { this.accID = accID; }

    public int getKanjiID() { return kanjiID; }
    public void setKanjiID(int kanjiID) { this.kanjiID = kanjiID; }

    public int getIsCorrect() { return isCorrect; }
    public void setIsCorrect(int isCorrect) { this.isCorrect = isCorrect; }

    public Timestamp getStudiedAt() { return studiedAt; }
    public void setStudiedAt(Timestamp studiedAt) { this.studiedAt = studiedAt; }
}