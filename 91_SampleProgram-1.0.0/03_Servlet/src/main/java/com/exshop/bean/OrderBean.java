package com.exshop.bean;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Integer userId;
    private String orderNumber;
    private String fullName;
    private String postalCode;
    private String address;
    private String phoneNumber;
    private String email;
    private String paymentMethod;
    private int totalPrice;
    private String status;
    private Timestamp createdAt;
    private List<OrderItemBean> items = new ArrayList<>();

    public OrderBean() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentMethodLabel() {
        if ("bank_transfer".equals(paymentMethod)) return "銀行振込";
        if ("cod".equals(paymentMethod)) return "代金引換";
        if ("convenience".equals(paymentMethod)) return "コンビニ決済";
        return "クレジットカード決済";
    }

    public int getTotalPrice() { return totalPrice; }
    public void setTotalPrice(int totalPrice) { this.totalPrice = totalPrice; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStatusLabel() {
        if ("pending".equals(status)) return "処理待ち";
        if ("processing".equals(status)) return "発送準備中";
        if ("shipped".equals(status)) return "発送済み";
        if ("cancelled".equals(status)) return "キャンセル";
        return "配達完了";
    }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<OrderItemBean> getItems() { return items; }
    public void setItems(List<OrderItemBean> items) { this.items = items; }
}
