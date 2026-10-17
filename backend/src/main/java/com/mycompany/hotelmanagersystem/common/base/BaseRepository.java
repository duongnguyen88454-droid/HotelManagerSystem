package com.mycompany.hotelmanagersystem.common.base;

import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Lớp trừu tượng nền tảng triển khai Repository Pattern trên nền JDBC thuần.
 * Tự động quản lý vòng đời đóng/mở kết nối, Statement và ResultSet,
 * đồng thời cung cấp các phương thức CRUD và truy vấn tái sử dụng cao.
 *
 * @param <T>  Kiểu Entity / Model
 * @param <ID> Kiểu khóa chính (String, Integer, Long...)
 */
public abstract class BaseRepository<T, ID> {

    protected abstract String getTableName();

    protected abstract String getPrimaryKeyColumnName();

    protected abstract RowMapper<T> getRowMapper();

    public Optional<T> findById(ID id) {
        String sql = "SELECT * FROM " + getTableName() + " WHERE " + getPrimaryKeyColumnName() + " = ?";
        return queryOne(sql, id);
    }

    public List<T> findAll() {
        String sql = "SELECT * FROM " + getTableName();
        return query(sql);
    }

    public boolean deleteById(ID id) {
        String sql = "DELETE FROM " + getTableName() + " WHERE " + getPrimaryKeyColumnName() + " = ?";
        return executeUpdate(sql, id) > 0;
    }

    protected List<T> query(String sql, Object... params) {
        return queryCustom(sql, getRowMapper(), params);
    }

    /**
     * Vai trò CSDL mặc định khi thực thi qua BaseRepository.
     * Các DAO con có thể ghi đè để chỉ định vai trò phù hợp (Manager, Receptionist...).
     *
     * @return Tên vai trò CSDL (mặc định là Customer)
     */
    protected String getRole() {
        return "Customer";
    }

    protected <R> List<R> queryCustom(String sql, RowMapper<R> mapper, Object... params) {
        List<R> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapper.mapRow(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi thực thi truy vấn SQL: " + sql, e);
        }
        return list;
    }

    protected Optional<T> queryOne(String sql, Object... params) {
        List<T> results = query(sql, params);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    protected <R> Optional<R> queryOneCustom(String sql, RowMapper<R> mapper, Object... params) {
        List<R> results = queryCustom(sql, mapper, params);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    protected int executeUpdate(String sql, Object... params) {
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            return ps.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi cập nhật CSDL với SQL: " + sql, e);
        }
    }

    protected boolean exists(String conditionSql, Object... params) {
        String sql = "SELECT 1 FROM " + getTableName() + " WHERE " + conditionSql;
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi kiểm tra tồn tại với SQL: " + sql, e);
        }
    }

    protected String queryScalarString(String sql, Object... params) {
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi lấy giá trị đơn với SQL: " + sql, e);
        }
        return null;
    }

    protected Long queryScalarLong(String sql, Object... params) {
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi lấy giá trị số nguyên với SQL: " + sql, e);
        }
        return null;
    }

    protected Double queryScalarDouble(String sql, Object... params) {
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new RuntimeException("Lỗi lấy giá trị số thực với SQL: " + sql, e);
        }
        return null;
    }

    protected void setParameters(PreparedStatement ps, Object... params) throws SQLException {
        if (params != null) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
        }
    }
}
