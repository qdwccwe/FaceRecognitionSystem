package com.face.servlet;

import com.face.model.User;
import com.face.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 个人中心控制器
 */
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("updateInfo".equals(action)) {
                // 更新个人信息
                String realName = request.getParameter("realName");
                String phone = request.getParameter("phone");
                String email = request.getParameter("email");

                loginUser.setRealName(realName);
                loginUser.setPhone(phone);
                loginUser.setEmail(email);

                if (userService.updateUser(loginUser)) {
                    session.setAttribute("loginUser", userService.getUserById(loginUser.getId()));
                    request.setAttribute("success", "个人信息更新成功");
                } else {
                    request.setAttribute("error", "更新失败");
                }

            } else if ("changePassword".equals(action)) {
                // 修改密码
                String oldPassword = request.getParameter("oldPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (oldPassword == null || oldPassword.isEmpty() ||
                        newPassword == null || newPassword.isEmpty()) {
                    request.setAttribute("error", "密码不能为空");
                } else if (newPassword.length() < 6) {
                    request.setAttribute("error", "新密码长度不能少于6位");
                } else if (!newPassword.equals(confirmPassword)) {
                    request.setAttribute("error", "两次输入的新密码不一致");
                } else if (userService.updatePassword(loginUser.getId(), oldPassword, newPassword)) {
                    request.setAttribute("success", "密码修改成功，下次登录时生效");
                } else {
                    request.setAttribute("error", "旧密码不正确");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "操作失败: " + e.getMessage());
        }

        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }
}
