package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.AccountDAO;
import model.AccountDTO;

/**
 * RegisterCon.java - 회원가입 처리 서블릿
 * 
 * [요청 URL] RegisterCon.do (POST)
 * [파라미터] nickname, email, userPw, userPw2
 * 
 * [처리 흐름]
 * 1. 빈 입력 체크 → 실패 시 register.jsp?error=empty
 * 2. 아이디(이메일) 중복 체크 → 실패 시 register.jsp?error=id
 * 3. 닉네임 중복 체크 → 실패 시 register.jsp?error=nickname
 * 4. 비밀번호 일치 확인 → 실패 시 register.jsp?error=pw
 * 5. DB에 회원 정보 저장 → 성공 시 login.jsp?msg=success
 * 
 * ★ account 테이블: accID는 자동생성, phone은 NULL 허용
 */
@WebServlet("/RegisterCon.do")
public class RegisterCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        reqPro(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        reqPro(request, response);
    }

    protected void reqPro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String nickname = request.getParameter("nickname");
        String email = request.getParameter("email");
        String userPw = request.getParameter("userPw");
        String userPw2 = request.getParameter("userPw2");

        // ========== 1. 빈 입력 체크 ==========
        if (nickname == null || nickname.isEmpty() ||
            email == null || email.isEmpty() ||
            userPw == null || userPw.isEmpty() ||
            userPw2 == null || userPw2.isEmpty()) {
            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        AccountDAO dao = new AccountDAO();

        // ========== 2. 아이디(이메일) 중복 체크 ==========
        if (dao.idCheck(email)) {
            response.sendRedirect("register.jsp?error=id");
            return;
        }

        // ========== 3. 닉네임 중복 체크 ==========
        if (dao.nicknameCheck(nickname)) {
            response.sendRedirect("register.jsp?error=nickname");
            return;
        }

        // ========== 4. 비밀번호 일치 확인 ==========
        if (!userPw.equals(userPw2)) {
            response.sendRedirect("register.jsp?error=pw");
            return;
        }

        // ========== 5. 회원 정보 저장 ==========
        // accID는 DB에서 자동 생성됨
        // phone은 회원가입 폼에 없으므로 NULL
        AccountDTO dto = new AccountDTO();
        dto.setUserID(email);       // userID = email
        dto.setUserPW1(userPw);
        dto.setUserPW2(userPw2);
        dto.setNickname(nickname);
        dto.setEmail(email);
        // dto.setPhone(null);  // phone은 NULL 허용이므로 설정 안 해도 됨

        dao.insertMember(dto);

        response.sendRedirect("login.jsp?msg=success");
    }
}