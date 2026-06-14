package com.face.servlet;

import com.face.model.User;
import com.face.service.UserService;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理员 - 用户管理控制器
 * 提供用户列表、搜索、删除等管理功能
 */
public class UserManageServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("search".equals(action)) {
                // 搜索用户
                String keyword = request.getParameter("keyword");
                List<User> users = userService.searchUsers(keyword);
                request.setAttribute("users", users);
                request.setAttribute("keyword", keyword);
            } else {
                // 默认：分页显示用户列表
                int page = 1;
                String pageStr = request.getParameter("page");
                if (pageStr != null) page = Integer.parseInt(pageStr);
                int pageSize = 10;

                List<User> users = userService.getAllUsers(page, pageSize);
                long totalCount = userService.getUserCount();
                int totalPages = (int) Math.ceil((double) totalCount / pageSize);

                request.setAttribute("users", users);
                request.setAttribute("page", page);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalCount", totalCount);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "查询失败: " + e.getMessage());
        }

        request.getRequestDispatcher("/jsp/admin/user_manage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        Map<String, Object> result = new HashMap<>();
        Gson gson = new Gson();

        try {
            if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                // 不允许删除自己
                User loginUser = (User) request.getSession().getAttribute("loginUser");
                if (loginUser != null && loginUser.getId() == userId) {
                    result.put("success", false);
                    result.put("message", "不能删除自己的账号");
                } else {
                    boolean ok = userService.deleteUser(userId);
                    result.put("success", ok);
                    result.put("message", ok ? "删除成功" : "删除失败");
                }
            } else if ("add".equals(action)) {
                // 管理员添加用户
                User newUser = new User();
                newUser.setUsername(request.getParameter("username"));
                newUser.setPassword(request.getParameter("password"));
                newUser.setRealName(request.getParameter("realName"));
                newUser.setRole(request.getParameter("role"));
                int regResult = userService.register(newUser);
                if (regResult == 1) {
                    result.put("success", true);
                    result.put("message", "添加成功");
                } else if (regResult == -1) {
                    result.put("success", false);
                    result.put("message", "用户名已存在");
                } else {
                    result.put("success", false);
                    result.put("message", "添加失败");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "操作失败: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }
}
