package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * LogoutCon.java - 로그아웃 처리 서블릿
 * 
 * [요청 URL] LogoutCon.do (GET)
 */
@WebServlet("/LogoutCon.do")
public class LogoutCon extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 세션 무효화 후 로그인 페이지로 이동
        HttpSession session = request.getSession();
        session.invalidate();
        response.sendRedirect("login.jsp");
    }
}