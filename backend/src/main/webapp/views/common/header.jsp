<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${not empty param.title ? param.title : (not empty pageTitle ? pageTitle : "Hệ Thống Quản Lý Khách
                Sạn - Nhóm 10")}</title>
    <!-- Link CSS Nền tảng Chuẩn (bổ sung cache-buster tự động) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tokens.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/utilities.css?v=<%= System.currentTimeMillis() %>">

    <c:choose>
        <c:when test="${param.zone eq 'portal'}">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layouts/portal.css?v=<%= System.currentTimeMillis() %>">
        </c:when>
        <c:otherwise>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layouts/public.css?v=<%= System.currentTimeMillis() %>">
        </c:otherwise>
    </c:choose>

    <c:if test="${not empty param.pageCss}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/${param.pageCss}?v=<%= System.currentTimeMillis() %>">
    </c:if>
</head>

        <body>
            <div class="content-wrapper">