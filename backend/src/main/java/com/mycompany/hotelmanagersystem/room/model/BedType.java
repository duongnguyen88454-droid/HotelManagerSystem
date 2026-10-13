package com.mycompany.hotelmanagersystem.room.model;

import java.io.Serializable;

/**
 * Entity ánh xạ bảng BedType (Loại giường) trong CSDL 3NF.
 */
public class BedType implements Serializable {
    private static final long serialVersionUID = 1L;

    private String bedTypeId;
    private String bedTypeName;
    private boolean isActive;

    public BedType() {
    }

    public BedType(String bedTypeId, String bedTypeName, boolean isActive) {
        this.bedTypeId = bedTypeId;
        this.bedTypeName = bedTypeName;
        this.isActive = isActive;
    }

    public String getBedTypeId() {
        return bedTypeId;
    }

    public void setBedTypeId(String bedTypeId) {
        this.bedTypeId = bedTypeId;
    }

    public String getBedTypeName() {
        return bedTypeName;
    }

    public void setBedTypeName(String bedTypeName) {
        this.bedTypeName = bedTypeName;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
