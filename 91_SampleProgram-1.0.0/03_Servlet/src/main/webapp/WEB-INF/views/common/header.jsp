<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle != null ? pageTitle : 'exShop - Luxury Collection'}"/></title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom Luxury CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/luxury.css">
</head>
<body class="d-flex flex-column min-vh-100">

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-luxury sticky-top py-3 shadow">
        <div class="container">
            <a class="navbar-brand brand-font brand-gold d-flex align-items-center gap-2 fs-3" href="${pageContext.request.contextPath}/">
                <i class="bi bi-gem"></i> exShop <span class="fs-6 fw-normal text-light-50 tracking-wider">L U X U R Y</span>
            </a>
            
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarMain">
                <!-- Search bar -->
                <form class="d-flex mx-auto my-2 my-lg-0 w-100" style="max-width: 420px;" method="get" action="${pageContext.request.contextPath}/products">
                    <div class="input-group">
                        <input class="form-control rounded-start-pill ps-3 bg-white" type="search" name="q" placeholder="ラグジュアリーアイテムを検索..." value="<c:out value='${param.q}'/>">
                        <button class="btn btn-gold rounded-end-pill px-4" type="submit">
                            <i class="bi bi-search"></i>
                        </button>
                    </div>
                </form>

                <ul class="navbar-nav ms-auto align-items-center gap-3">
                    <!-- Tags Dropdown -->
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-light" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-tags me-1"></i> コレクション
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products">すべてのアイテム</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <c:forEach var="tag" items="${allTags}">
                                <li>
                                    <a class="dropdown-item d-flex justify-content-between align-items-center" href="${pageContext.request.contextPath}/products?tag=${tag.slug}">
                                        ${tag.name}
                                        <span class="badge rounded-pill bg-light text-dark border">${tag.productCount}</span>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </li>

                    <!-- Add product button (Staff/All) -->
                    <li class="nav-item">
                        <a class="btn btn-sm btn-outline-gold rounded-pill px-3" href="${pageContext.request.contextPath}/products/create">
                            <i class="bi bi-plus-lg me-1"></i> 出品登録
                        </a>
                    </li>

                    <!-- Favorites -->
                    <li class="nav-item">
                        <a class="nav-link position-relative text-light px-2" href="${pageContext.request.contextPath}/favorites" title="お気に入り">
                            <i class="bi bi-suit-heart fs-5"></i>
                            <c:if test="${favoriteCount > 0}">
                                <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 0.65rem;">
                                    ${favoriteCount}
                                </span>
                            </c:if>
                        </a>
                    </li>

                    <!-- Cart -->
                    <li class="nav-item">
                        <a class="nav-link position-relative text-light px-2" href="${pageContext.request.contextPath}/cart" title="ショッピングバッグ">
                            <i class="bi bi-bag-check fs-5"></i>
                            <c:if test="${cart.totalCount > 0}">
                                <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill btn-gold" style="font-size: 0.65rem;">
                                    ${cart.totalCount}
                                </span>
                            </c:if>
                        </a>
                    </li>

                    <!-- User Account -->
                    <c:choose>
                        <c:when test="${not empty sessionScope.loginUser}">
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle text-light d-flex align-items-center gap-2" href="#" role="button" data-bs-toggle="dropdown">
                                    <i class="bi bi-person-circle fs-5 brand-gold"></i>
                                    <span><c:out value="${sessionScope.loginUser.username}"/></span>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                    <li class="dropdown-header">サロン会員: ${sessionScope.loginUser.username} 様</li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth/mypage"><i class="bi bi-person me-2"></i>マイページ</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/orders"><i class="bi bi-receipt me-2"></i>ご注文履歴</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/favorites"><i class="bi bi-suit-heart me-2"></i>お気に入り一覧</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right me-2"></i>ログアウト</a></li>
                                </ul>
                            </li>
                        </c:when>
                        <c:otherwise>
                            <li class="nav-item ms-lg-2">
                                <a class="btn btn-sm btn-outline-gold rounded-pill px-3" href="${pageContext.request.contextPath}/auth/login">ログイン</a>
                            </li>
                            <li class="nav-item">
                                <a class="btn btn-sm btn-gold rounded-pill px-3" href="${pageContext.request.contextPath}/auth/signup">新規登録</a>
                            </li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Flash Messages -->
    <div class="container mt-3">
        <c:if test="${not empty flashMessage}">
            <div class="alert alert-${flashType} alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-info-circle-fill me-2"></i> <c:out value="${flashMessage}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
    </div>

    <main class="flex-grow-1">
