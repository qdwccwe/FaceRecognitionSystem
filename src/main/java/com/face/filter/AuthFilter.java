package com.face.filter;

import com.face.model.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 权限过滤器
 * 拦截所有请求，检查用户登录状态和权限
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println(">>> 权限过滤器初始化完成");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        // 设置编码
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // ============ 放行的公共资源 ============
        // 静态资源
        if (path.startsWith("/css/") || path.startsWith("/js/") ||
                path.startsWith("/images/") || path.startsWith("/uploads/")) {
            chain.doFilter(request, response);
            return;
        }

        // 登录、注册、退出
        if (path.equals("/login") || path.equals("/register") ||
                path.equals("/faceLogin") || path.equals("/logout") ||
                path.equals("/jsp/login.jsp") || path.equals("/jsp/register.jsp")) {
            chain.doFilter(request, response);
            return;
        }

        // 错误页面
        if (path.startsWith("/jsp/error/")) {
            chain.doFilter(request, response);
            return;
        }

        // ============ 需要登录的页面 ============
        HttpSession session = request.getSession(false);
        User loginUser = null;
        if (session != null) {
            loginUser = (User) session.getAttribute("loginUser");
        }

        if (loginUser == null) {
            // 未登录，跳转到登录页
            response.sendRedirect(contextPath + "/jsp/login.jsp");
            return;
        }

        // ============ 管理员权限检查 ============
        if (path.startsWith("/admin/")) {
            if (!"admin".equals(loginUser.getRole())) {
                // 非管理员，拒绝访问
                response.sendRedirect(contextPath + "/jsp/error/403.jsp");
                return;
            }
        }

        // 放行
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        System.out.println(">>> 权限过滤器已销毁");
    }
}
