<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${not empty param.title ? param.title : (not empty pageTitle ? pageTitle : "Hệ Thống Quản Lý Khách
                Sạn - Nhóm 10")}</title>
    <!-- Link CSS Nền tảng Chuẩn -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tokens.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/utilities.css">

    <c:choose>
        <c:when test="${param.zone eq 'portal'}">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layouts/portal.css">
        </c:when>
        <c:otherwise>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layouts/public.css">
        </c:otherwise>
    </c:choose>

    <c:if test="${not empty param.pageCss}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/${param.pageCss}">
    </c:if>
</head>

        <body>
            <div class="content-wrapper">