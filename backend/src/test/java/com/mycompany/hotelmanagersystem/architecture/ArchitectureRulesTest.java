package com.mycompany.hotelmanagersystem.architecture;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.library.freeze.FreezingArchRule;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;
import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

/**
 * Kiểm tra kiến trúc ở mức BYTECODE (lớp bảo vệ thứ 2, bổ sung cho Checkstyle ImportControl).
 * Bắt được cả trường hợp Checkstyle không thấy: dùng tên đầy đủ (không import), kiểu của field/tham số...
 * Giải thích từng quy tắc: .agents/rules/ARCHITECTURE_RULES.md (mục 3).
 *
 * Nợ cũ được "đóng băng" trong src/test/resources/archunit_store: vi phạm CŨ không làm đỏ build,
 * vi phạm MỚI thì làm đỏ build. Khi sửa xong một nợ, store tự rút gọn.
 * CẤM tự xóa/sửa thư mục archunit_store để "cho qua" (QT 5.3).
 */
@AnalyzeClasses(packages = "com.mycompany.hotelmanagersystem",
        importOptions = ImportOption.DoNotIncludeTests.class)
public class ArchitectureRulesTest {

    /** Đổi thành true SAU KHI repo đã chuyển sang cấu trúc chia theo feature (booking.controller, booking.dao...). */
    private static final boolean FEATURE_BASED = true;

    private static final String BASE = "com.mycompany.hotelmanagersystem";

    /** Trả về mẫu package của một tầng, ví dụ layer("dao") -> "...hotelmanagersystem.dao.." */
    private static String layer(String name) {
        return FEATURE_BASED ? BASE + ".*." + name + ".." : BASE + "." + name + "..";
    }

    // ===== QT 3.x: chiều phụ thuộc giữa các tầng =====

    @ArchTest
    static final ArchRule phan_tang = FreezingArchRule.freeze(
            layeredArchitecture()
                    .consideringOnlyDependenciesInLayers()
                    .layer("Controller").definedBy(layer("controller"))
                    .layer("Filter").definedBy(layer("filter"))
                    .layer("Service").definedBy(layer("service"))
                    .layer("Dao").definedBy(layer("dao"))
                    .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
                    .whereLayer("Filter").mayNotBeAccessedByAnyLayer()
                    .whereLayer("Service").mayOnlyBeAccessedByLayers("Controller", "Filter")
                    .whereLayer("Dao").mayOnlyBeAccessedByLayers("Service")
                    .because("Controller chi goi Service, Service chi goi Dao (QT 3.1-3.3)"));

    @ArchTest
    static final ArchRule controller_va_service_khong_dung_jdbc = FreezingArchRule.freeze(
            noClasses().that().resideInAnyPackage(layer("controller"), layer("service"))
                    .should().dependOnClassesThat().resideInAPackage("java.sql..")
                    .because("JDBC chi duoc nam o tang Dao; Service dung java.time thay cho java.sql.Date (QT 3.1, 3.2)"));

    @ArchTest
    static final ArchRule controller_khong_dung_dbcontext = FreezingArchRule.freeze(
            noClasses().that().resideInAnyPackage(layer("controller"), layer("service"), layer("filter"))
                    .should().dependOnClassesThat().haveSimpleName("DBContext")
                    .because("Chi Dao duoc mo ket noi CSDL (QT 3.1)"));

    @ArchTest
    static final ArchRule service_va_dao_khong_biet_http = FreezingArchRule.freeze(
            noClasses().that().resideInAnyPackage(layer("service"), layer("dao"), layer("dto"), layer("model"))
                    .should().dependOnClassesThat().resideInAnyPackage("javax.servlet..", "jakarta.servlet..")
                    .because("Chi Controller/Filter duoc biet HttpServletRequest/Session (QT 3.2, 3.3, 3.4)"));

    @ArchTest
    static final ArchRule dto_model_chi_la_du_lieu = FreezingArchRule.freeze(
            noClasses().that().resideInAnyPackage(layer("dto"), layer("model"))
                    .should().dependOnClassesThat().resideInAnyPackage(layer("controller"), layer("service"), layer("dao"))
                    .because("DTO/Model khong chua logic truy cap du lieu hay nghiep vu (QT 3.4)"));

    @ArchTest
    static final ArchRule servlet_phai_nam_trong_controller = FreezingArchRule.freeze(
            classes().that().areAnnotatedWith("javax.servlet.annotation.WebServlet")
                    .should().resideInAPackage(layer("controller"))
                    .because("Moi @WebServlet phai nam trong goi controller (QT 3.1)"));

    // ===== QT 3.6: chi ap dung khi da chuyen sang chia theo feature =====

    @ArchTest
    static void feature_khong_phu_thuoc_vong(JavaClasses classes) {
        if (!FEATURE_BASED) {
            return;
        }
        slices().matching(BASE + ".(*)..").should().beFreeOfCycles().check(classes);
    }
}
