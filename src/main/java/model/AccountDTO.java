package model;

/**
 * AccountDTO.java - 회원 정보 담는 클래스
 * 
 * DB account 테이블 매핑:
 * - accID     : 내부 PK (NUMBER, 자동생성)
 * - userID    : 로그인 ID (VARCHAR2(50), UNIQUE)
 * - userPW1   : 비밀번호
 * - userPW2   : 비밀번호 확인
 * - email     : 이메일
 * - phone     : 전화번호
 * - attendance: 출석 (실제 출석은 kanji_log 기반)
 * - nickname  : 닉네임
 * 
 * ※ regDate 컬럼은 DB에 없음 → 가입일은 kanji_log 최초 기록 또는 별도 관리
 */
public class AccountDTO {

    private int accID;          // 내부 PK (자동생성)
    private String userID;      // 로그인 ID
    private String userPW1;     // 비밀번호
    private String userPW2;     // 비밀번호 확인
    private String email;       // 이메일
    private String phone;       // 전화번호
    private String attendance;  // 출석 (DB 컬럼은 있지만 실제 출석은 kanji_log 기반)
    private String nickname;    // 닉네임
    private String regDate;     // 가입일 (TIMESTAMP DEFAULT SYSTIMESTAMP)

    // ========== Getter / Setter ==========

    public int getAccID() { return accID; }
    public void setAccID(int accID) { this.accID = accID; }

    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }

    public String getUserPW1() { return userPW1; }
    public void setUserPW1(String userPW1) { this.userPW1 = userPW1; }

    public String getUserPW2() { return userPW2; }
    public void setUserPW2(String userPW2) { this.userPW2 = userPW2; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAttendance() { return attendance; }
    public void setAttendance(String attendance) { this.attendance = attendance; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getRegDate() { return regDate; }
    public void setRegDate(String regDate) { this.regDate = regDate; }
}