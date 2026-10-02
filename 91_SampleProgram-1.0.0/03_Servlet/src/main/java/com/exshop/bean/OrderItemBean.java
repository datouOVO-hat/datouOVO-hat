package com.exshop.bean;

import java.io.Serializable;

public class OrderItemBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int orderId;
    private Integer productId;
    private String productName;
    private int price;
    private int quantity;

    public OrderItemBean() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getSubtotal() { return price * quantity; }
}
