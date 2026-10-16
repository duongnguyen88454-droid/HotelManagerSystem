package com.mycompany.hotelmanagersystem.manager.dto;

import java.math.BigDecimal;

/**
 * DTO dữ liệu báo cáo Doanh Thu Sản Phẩm & Dịch Vụ cho Manager.
 */
public class ProductRevenueItemDTO {

    private String serviceId;
    private String serviceName;
    private BigDecimal basePrice;
    private int quantitySold;
    private BigDecimal totalRevenue;

    public ProductRevenueItemDTO() {
    }

    public ProductRevenueItemDTO(String serviceId, String serviceName, BigDecimal basePrice,
                                 int quantitySold, BigDecimal totalRevenue) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.basePrice = (basePrice != null) ? basePrice : BigDecimal.ZERO;
        this.quantitySold = quantitySold;
        this.totalRevenue = (totalRevenue != null) ? totalRevenue : BigDecimal.ZERO;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public int getQuantitySold() {
        return quantitySold;
    }

    public void setQuantitySold(int quantitySold) {
        this.quantitySold = quantitySold;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }
}
