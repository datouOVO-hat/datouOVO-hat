<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="${product.name} - exShop Luxury"/>
</jsp:include>

<div class="container py-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/products" class="text-decoration-none text-muted">コレクション</a></li>
            <li class="breadcrumb-item active text-truncate" style="max-width: 300px;"><c:out value="${product.name}"/></li>
        </ol>
    </nav>

    <div class="row g-5">
        <!-- Image -->
        <div class="col-lg-6">
            <div class="card luxury-card p-3 shadow-sm text-center">
                <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="<c:out value='${product.name}'/>" class="img-fluid rounded" style="max-height: 480px; width: 100%; object-fit: contain;">
            </div>
        </div>

        <!-- Details -->
        <div class="col-lg-6 d-flex flex-column">
            <div class="mb-2 d-flex flex-wrap gap-1">
                <c:forEach var="tag" items="${product.tags}">
                    <span class="gold-badge">${tag.name}</span>
                </c:forEach>
            </div>

            <h1 class="brand-font fs-2 text-dark mb-3"><c:out value="${product.name}"/></h1>

            <div class="p-3 bg-white rounded border mb-4 shadow-sm">
                <div class="d-flex align-items-baseline gap-2 mb-2">
                    <span class="display-6 price-gold">&yen;<fmt:formatNumber value="${product.price}" pattern="#,###"/></span>
                    <span class="text-muted small">(税込・送料無料)</span>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${product.inStock}">
                            <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-pill">
                                <i class="bi bi-check-circle me-1"></i> 在庫あり（残り ${product.stock} 点）
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-1 rounded-pill">売り切れ</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <h5 class="fw-bold mb-2">アイテム詳細</h5>
            <div class="text-muted lh-lg mb-4" style="white-space: pre-line;">
                <c:out value="${product.description}"/>
            </div>

            <!-- Add to Cart Form -->
            <c:if test="${product.inStock}">
                <form action="${pageContext.request.contextPath}/cart/add" method="post" class="mt-auto pt-3 border-top">
                    <input type="hidden" name="productId" value="${product.id}">
                    <div class="row g-3 align-items-center">
                        <div class="col-auto">
                            <label for="quantity" class="col-form-label fw-bold">数量:</label>
                        </div>
                        <div class="col-auto">
                            <select name="quantity" id="quantity" class="form-select">
                                <c:forEach var="i" begin="1" end="${product.stock > 10 ? 10 : product.stock}">
                                    <option value="${i}">${i}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col">
                            <button type="submit" class="btn btn-gold btn-lg w-100 rounded-pill shadow-sm">
                                <i class="bi bi-bag-plus me-2"></i> ショッピングバッグに追加
                            </button>
                        </div>
                    </div>
                </form>
            </c:if>
        </div>
    </div>

    <!-- Related Products -->
    <c:if test="${not empty relatedProducts}">
        <div class="mt-5 pt-5 border-top">
            <h3 class="brand-font mb-4">こちらもおすすめのコレクション</h3>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
                <c:forEach var="rel" items="${relatedProducts}">
                    <div class="col">
                        <div class="card luxury-card h-100 p-2 text-center">
                            <a href="${pageContext.request.contextPath}/products/detail?id=${rel.id}" class="text-decoration-none">
                                <img src="${pageContext.request.contextPath}/${rel.imageUrl}" alt="<c:out value='${rel.name}'/>" class="img-fluid rounded mb-2" style="height: 160px; width: 100%; object-fit: cover;">
                                <div class="text-dark fw-bold small text-truncate"><c:out value="${rel.name}"/></div>
                                <div class="price-gold small mt-1">&yen;<fmt:formatNumber value="${rel.price}" pattern="#,###"/></div>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
