package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.ManagerDashboardDAO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomOccupancyDTO;

public class ManagerDashboardService {

    private final ManagerDashboardDAO dashboardDAO;

    public ManagerDashboardService() {
        this.dashboardDAO = new ManagerDashboardDAO();
    }

    public ManagerDashboardService(ManagerDashboardDAO dashboardDAO) {
        this.dashboardDAO = dashboardDAO;
    }

    public RoomOccupancyDTO getOccupancySummary() {
        return dashboardDAO.getOccupancySummary();
    }
}
