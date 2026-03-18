package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Brand;

public class BrandUtils {
    
    public static List<Brand> getAllBrands(Connection conn) throws SQLException {
        String sql = "SELECT * FROM brands";
        PreparedStatement pstm = conn.prepareStatement(sql);
        ResultSet rs = pstm.executeQuery();
        List<Brand> list = new ArrayList<>();
        while (rs.next()) {
            Brand brand = new Brand();
            brand.setId(rs.getInt("id"));
            brand.setName(rs.getString("name"));
            brand.setLogoUrl(rs.getString("logo_url"));
            list.add(brand);
        }
        return list;
    }

    public static Brand getBrandById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM brands WHERE id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, id);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            Brand brand = new Brand();
            brand.setId(rs.getInt("id"));
            brand.setName(rs.getString("name"));
            brand.setLogoUrl(rs.getString("logo_url"));
            return brand;
        }
        return null;
    }
}
