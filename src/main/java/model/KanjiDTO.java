package model;

import java.sql.Timestamp;

/**
 * KanjiDTO.java - 한자 정보 담는 클래스
 * 
 * DB kanji 테이블 매핑:
 * - kanjiID            : PK (NUMBER, 자동생성)
 * - kanjiindex         : 인덱스 코드 (예: "N5-001")
 * - kanji              : 한자 문자 (NCHAR(1))
 * - onyomi1~3          : 음독 1~3
 * - kunyomi1~3         : 훈독 1~3
 * - korean_meaning     : 한국어 뜻 (예: "해, 날")
 * - meaning_description: 의미 설명
 * - example1~3         : 예시 단어 1~3
 * - jlpt_level         : JLPT 레벨 (N5~N1)
 * - sector             : 섹터 번호
 * - index_num          : 섹터 내 인덱스
 * - created_at         : 생성일
 * - updated_at         : 수정일
 */
public class KanjiDTO {

    private int kanjiID;                // PK (자동생성)
    private String kanjiindex;          // 인덱스 코드 (예: "N5-001")
    private String kanji;               // 한자 문자
    private String onyomi1;             // 음독 1
    private String onyomi2;             // 음독 2
    private String onyomi3;             // 음독 3
    private String kunyomi1;            // 훈독 1
    private String kunyomi2;            // 훈독 2
    private String kunyomi3;            // 훈독 3
    private String koreanMeaning;       // 한국어 뜻
    private String meaningDescription;  // 의미 설명
    private String example1;            // 예시 1
    private String example2;            // 예시 2
    private String example3;            // 예시 3
    private String jlptLevel;           // JLPT 레벨 (N5, N4, N3, N2, N1)
    private int sector;                 // 섹터 번호
    private int indexNum;               // 섹터 내 인덱스
    private Timestamp createdAt;        // 생성일
    private Timestamp updatedAt;        // 수정일

    // ========== 기본 생성자 ==========
    public KanjiDTO() {}

    // ========== Getter / Setter ==========

    public int getKanjiID() { return kanjiID; }
    public void setKanjiID(int kanjiID) { this.kanjiID = kanjiID; }

    public String getKanjiindex() { return kanjiindex; }
    public void setKanjiindex(String kanjiindex) { this.kanjiindex = kanjiindex; }

    public String getKanji() { return kanji; }
    public void setKanji(String kanji) { this.kanji = kanji; }

    public String getOnyomi1() { return onyomi1; }
    public void setOnyomi1(String onyomi1) { this.onyomi1 = onyomi1; }

    public String getOnyomi2() { return onyomi2; }
    public void setOnyomi2(String onyomi2) { this.onyomi2 = onyomi2; }

    public String getOnyomi3() { return onyomi3; }
    public void setOnyomi3(String onyomi3) { this.onyomi3 = onyomi3; }

    public String getKunyomi1() { return kunyomi1; }
    public void setKunyomi1(String kunyomi1) { this.kunyomi1 = kunyomi1; }

    public String getKunyomi2() { return kunyomi2; }
    public void setKunyomi2(String kunyomi2) { this.kunyomi2 = kunyomi2; }

    public String getKunyomi3() { return kunyomi3; }
    public void setKunyomi3(String kunyomi3) { this.kunyomi3 = kunyomi3; }

    public String getKoreanMeaning() { return koreanMeaning; }
    public void setKoreanMeaning(String koreanMeaning) { this.koreanMeaning = koreanMeaning; }

    public String getMeaningDescription() { return meaningDescription; }
    public void setMeaningDescription(String meaningDescription) { this.meaningDescription = meaningDescription; }

    public String getExample1() { return example1; }
    public void setExample1(String example1) { this.example1 = example1; }

    public String getExample2() { return example2; }
    public void setExample2(String example2) { this.example2 = example2; }

    public String getExample3() { return example3; }
    public void setExample3(String example3) { this.example3 = example3; }

    public String getJlptLevel() { return jlptLevel; }
    public void setJlptLevel(String jlptLevel) { this.jlptLevel = jlptLevel; }

    public int getSector() { return sector; }
    public void setSector(int sector) { this.sector = sector; }

    public int getIndexNum() { return indexNum; }
    public void setIndexNum(int indexNum) { this.indexNum = indexNum; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}