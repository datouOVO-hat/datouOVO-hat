<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="コレクション一覧 - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <!-- Hero Banner (Only on initial load) -->
    <c:if test="${empty query and empty tagSlug and currentPage == 1}">
        <div class="hero-luxury mb-5 text-center shadow-lg">
            <span class="badge gold-badge text-uppercase tracking-wider px-3 py-2 mb-3">Autumn & Winter Collection 2026</span>
            <h1 class="display-4 brand-font text-white mb-3">エレガンスを纏う、極上の日常</h1>
            <p class="lead text-light-50 mx-auto" style="max-width: 640px; font-weight: 300;">
                選りすぐりのデザイナーズアパレル、上質なレザーバッグ、希少なヴィンテージコレクションまで。<br>
                特別なひとときを彩る洗練のラインナップ。
            </p>
            <div class="mt-4">
                <a href="#collection" class="btn btn-gold rounded-pill px-5 py-2">コレクションを見る <i class="bi bi-chevron-down ms-1"></i></a>
            </div>
        </div>
    </c:if>

    <!-- Filters & Sort -->
    <div id="collection" class="mb-4">
        <div class="row align-items-center g-3">
            <div class="col-lg-8">
                <div class="d-flex flex-wrap gap-2 align-items-center">
                    <span class="text-muted small fw-semibold"><i class="bi bi-filter"></i> カテゴリ:</span>
                    <a href="${pageContext.request.contextPath}/products<c:if test='${not empty query}'>?q=${query}</c:if>" 
                       class="btn btn-sm ${empty tagSlug ? 'btn-gold' : 'btn-outline-secondary'} rounded-pill px-3">
                        すべて
                    </a>
                    <c:forEach var="tag" items="${allTags}">
                        <a href="${pageContext.request.contextPath}/products?tag=${tag.slug}<c:if test='${not empty query}'>&q=${query}</c:if>" 
                           class="btn btn-sm ${tagSlug == tag.slug ? 'btn-gold' : 'btn-outline-secondary'} rounded-pill px-3">
                            ${tag.name}
                        </a>
                    </c:forEach>
                </div>
            </div>

            <div class="col-lg-4 text-lg-end">
                <form method="get" action="${pageContext.request.contextPath}/products" class="d-inline-flex align-items-center gap-2">
                    <c:if test="${not empty query}"><input type="hidden" name="q" value="<c:out value='${query}'/>"></c:if>
                    <c:if test="${not empty tagSlug}"><input type="hidden" name="tag" value="<c:out value='${tagSlug}'/>"></c:if>
                    <label for="sort" class="text-muted small text-nowrap">並び替え:</label>
                    <select name="sort" id="sort" class="form-select form-select-sm" style="width: auto;" onchange="this.form.submit()">
                        <option value="newest" ${sort == 'newest' ? 'selected' : ''}>新着順</option>
                        <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>価格の安い順</option>
                        <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>価格の高い順</option>
                    </select>
                </form>
            </div>
        </div>

        <c:if test="${not empty query or not empty selectedTag}">
            <div class="mt-3 p-3 bg-white rounded border d-flex justify-content-between align-items-center">
                <span class="text-muted small">
                    <c:if test="${not empty query}">検索ワード: <strong>"<c:out value='${query}'/>"</strong></c:if>
                    <c:if test="${not empty selectedTag}">タグ: <span class="badge gold-badge">${selectedTag.name}</span></c:if>
                    （${totalCount} 点）
                </span>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-sm btn-link text-danger text-decoration-none">
                    <i class="bi bi-x-circle"></i> 絞り込み解除
                </a>
            </div>
        </c:if>
    </div>

    <!-- Product Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
        <c:forEach var="p" items="${products}">
            <div class="col">
                <div class="card h-100 luxury-card shadow-sm position-relative">
                    <!-- Favorite Button -->
                    <c:if test="${not empty sessionScope.loginUser}">
                        <form action="${pageContext.request.contextPath}/favorites/toggle" method="post" class="position-absolute" style="top: 10px; right: 10px; z-index: 5;">
                            <input type="hidden" name="productId" value="${p.id}">
                            <button type="submit" class="btn btn-light rounded-circle shadow-sm p-0 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;" title="お気に入りに追加/解除">
                                <c:choose>
                                    <c:when test="${favoriteProductIds.contains(p.id)}">
                                        <i class="bi bi-suit-heart-fill text-danger fs-6"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="bi bi-suit-heart text-secondary fs-6"></i>
                                    </c:otherwise>
                                </c:choose>
                            </button>
                        </form>
                    </c:if>

                    <!-- Image -->
                    <a href="${pageContext.request.contextPath}/products/detail?id=${p.id}" class="luxury-img-wrapper text-decoration-none">
                        <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="<c:out value='${p.name}'/>" loading="lazy">
                    </a>

                    <div class="card-body d-flex flex-column p-3">
                        <div class="mb-2 d-flex flex-wrap gap-1">
                            <c:forEach var="tag" items="${p.tags}">
                                <span class="gold-badge">${tag.name}</span>
                            </c:forEach>
                        </div>

                        <h6 class="card-title fw-bold mb-1 text-truncate">
                            <a href="${pageContext.request.contextPath}/products/detail?id=${p.id}" class="text-dark text-decoration-none">
                                <c:out value="${p.name}"/>
                            </a>
                        </h6>

                        <p class="card-text text-muted small mb-3 flex-grow-1 text-truncate" style="max-height: 2.4em;">
                            <c:out value="${p.description}"/>
                        </p>

                        <div class="d-flex justify-content-between align-items-baseline pt-2 border-top">
                            <span class="fs-5 price-gold">&yen;<fmt:formatNumber value="${p.price}" pattern="#,###"/></span>
                            <c:choose>
                                <c:when test="${p.inStock}">
                                    <span class="badge bg-light text-success border border-success-subtle rounded-pill">在庫あり (${p.stock})</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-danger border border-danger-subtle rounded-pill">売り切れ</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <c:if test="${p.inStock}">
                            <form action="${pageContext.request.contextPath}/cart/add" method="post" class="mt-3">
                                <input type="hidden" name="productId" value="${p.id}">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn btn-outline-dark btn-sm w-100 rounded-pill">
                                    <i class="bi bi-bag-plus me-1"></i> バッグに追加
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav class="mt-5">
            <ul class="pagination justify-content-center">
                <c:forEach var="i" begin="1" end="${totalPages}">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/products?page=${i}<c:if test='${not empty query}'>&q=${query}</c:if><c:if test='${not empty tagSlug}'>&tag=${tagSlug}</c:if><c:if test='${not empty sort}'>&sort=${sort}</c:if>">
                            ${i}
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
