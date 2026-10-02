package com.exshop.bean;

import java.io.Serializable;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class CartBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private Map<Integer, CartItemBean> items = new LinkedHashMap<>();

    public CartBean() {}

    public void add(ProductBean product, int quantity) {
        int id = product.getId();
        if (items.containsKey(id)) {
            CartItemBean item = items.get(id);
            item.setQuantity(item.getQuantity() + quantity);
        } else {
            items.put(id, new CartItemBean(product, quantity));
        }
    }

    public void update(int productId, int quantity) {
        if (items.containsKey(productId)) {
            if (quantity <= 0) {
                items.remove(productId);
            } else {
                items.get(productId).setQuantity(quantity);
            }
        }
    }

    public void remove(int productId) {
        items.remove(productId);
    }

    public void clear() {
        items.clear();
    }

    public Collection<CartItemBean> getItems() {
        return items.values();
    }

    public int getTotalCount() {
        return items.values().stream().mapToInt(CartItemBean::getQuantity).sum();
    }

    public int getTotalPrice() {
        return items.values().stream().mapToInt(CartItemBean::getSubtotal).sum();
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }
}
