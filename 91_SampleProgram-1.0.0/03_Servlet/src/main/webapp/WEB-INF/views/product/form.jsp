<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="pageTitle" value="商品登録 - exShop Luxury"/>
</jsp:include>

<div class="container py-4" style="max-width: 700px;">
    <div class="card luxury-card p-4 shadow-sm">
        <h3 class="brand-font mb-3"><i class="bi bi-gem me-2 brand-gold"></i>新作コレクション出品・登録</h3>
        <p class="text-muted small mb-4">サロンに出品するアイテム情報を入力してください。</p>

        <form method="post" action="${pageContext.request.contextPath}/products/create">
            <div class="mb-3">
                <label class="form-label fw-bold">アイテム名 <span class="text-danger">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="例: プレミアム サフィアーノレザートート" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">アイテム説明</label>
                <textarea name="description" class="form-control" rows="4" placeholder="素材、仕立て、原産国、スタイリングの提案など"></textarea>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold">販売価格 (円) <span class="text-danger">*</span></label>
                    <input type="number" name="price" class="form-control" min="0" step="100" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">初期在庫数 <span class="text-danger">*</span></label>
                    <input type="number" name="stock" class="form-control" min="0" value="10" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">画像ファイルパス (media/配下)</label>
                <input type="text" name="image" class="form-control" placeholder="例: products/bag_lady/Image_fx (1).jpg">
                <div class="form-text text-muted small">
                    ※ 未入力の場合は自動的に <code>no-image.png</code> が適用されます。
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold d-block">関連タグの選択</label>
                <div class="d-flex flex-wrap gap-3 p-3 bg-light rounded border">
                    <c:forEach var="tag" items="${allTags}">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="tagIds" value="${tag.id}" id="tag_${tag.id}">
                            <label class="form-check-label small" for="tag_${tag.id}">${tag.name}</label>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="d-flex justify-content-between pt-3 border-top">
                <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-secondary rounded-pill px-4">キャンセル</a>
                <button type="submit" class="btn btn-gold rounded-pill px-5 fw-bold">出品・登録を完了する</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
