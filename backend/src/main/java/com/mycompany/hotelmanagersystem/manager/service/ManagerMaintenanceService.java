package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.MaintenanceDAO;
import com.mycompany.hotelmanagersystem.manager.dto.DamagedRoomItemDTO;

import java.util.List;

public class ManagerMaintenanceService {

    private final MaintenanceDAO maintenanceDAO;

    public ManagerMaintenanceService() {
        this.maintenanceDAO = new MaintenanceDAO();
    }

    public ManagerMaintenanceService(MaintenanceDAO maintenanceDAO) {
        this.maintenanceDAO = maintenanceDAO;
    }

    public List<DamagedRoomItemDTO> getPendingDamagedRooms() {
        return maintenanceDAO.getPendingDamagedRooms();
    }

    public boolean resolveDamagedRoom(String maBaoCao, String maPhong) {
        if (maBaoCao == null || maBaoCao.trim().isEmpty()
                || maPhong == null || maPhong.trim().isEmpty()) {
            return false;
        }
        return maintenanceDAO.resolveDamagedRoom(maBaoCao.trim(), maPhong.trim());
    }
}
