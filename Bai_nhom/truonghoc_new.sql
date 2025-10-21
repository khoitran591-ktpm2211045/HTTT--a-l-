-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 13, 2025 at 07:26 AM
-- Server version: 8.0.41
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `truonghoc`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ThongKeTongQuan` ()   BEGIN
    SELECT 
        'Tổng số trường' as chi_tieu,
        COUNT(*) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Tổng số học sinh' as chi_tieu,
        SUM(so_hoc_sinh) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Trung bình học sinh/trường' as chi_tieu,
        ROUND(AVG(so_hoc_sinh), 0) as gia_tri
    FROM truong_hoc
    UNION ALL
    SELECT 
        'Trường có nhiều học sinh nhất' as chi_tieu,
        MAX(so_hoc_sinh) as gia_tri
    FROM truong_hoc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TimTruongCoHocSinhLonHon` (IN `so_hoc_sinh_min` INT)   BEGIN
    SELECT 
        th.ma_truong,
        th.ten_truong,
        ch.ten_cap_hoc,
        lt.ten_loai_truong,
        qh.ten_quan_huyen,
        th.dia_chi,
        th.so_hoc_sinh,
        ST_X(th.toa_do) as longitude,
        ST_Y(th.toa_do) as latitude
    FROM truong_hoc th
    JOIN cap_hoc ch ON th.ma_cap_hoc = ch.ma_cap_hoc
    JOIN loai_truong lt ON th.ma_loai_truong = lt.ma_loai_truong
    JOIN quan_huyen qh ON th.ma_quan_huyen = qh.ma_quan_huyen
    WHERE th.so_hoc_sinh > so_hoc_sinh_min
    ORDER BY th.so_hoc_sinh DESC;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `KiemTraToaDoCanTho` (`lat` DECIMAL(10,8), `lon` DECIMAL(11,8)) RETURNS TINYINT(1) DETERMINISTIC READS SQL DATA BEGIN
    -- Tọa độ Cần Thơ: 9.8°N - 10.3°N, 105.4°E - 105.9°E
    IF lat BETWEEN 9.8 AND 10.3 AND lon BETWEEN 105.4 AND 105.9 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TinhKhoangCach` (`lat1` DECIMAL(10,8), `lon1` DECIMAL(11,8), `lat2` DECIMAL(10,8), `lon2` DECIMAL(11,8)) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE distance DECIMAL(10,2);
    SET distance = SQRT(POW(69.1 * (lat2 - lat1), 2) + 
                       POW(69.1 * (lon2 - lon1) * COS(lat1 / 57.3), 2));
    RETURN distance;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cap_hoc`
--

CREATE TABLE `cap_hoc` (
  `ma_cap_hoc` varchar(10) NOT NULL,
  `ten_cap_hoc` varchar(50) NOT NULL,
  `thu_tu` int DEFAULT NULL,
  `mo_ta` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `cap_hoc`
--

INSERT INTO `cap_hoc` (`ma_cap_hoc`, `ten_cap_hoc`, `thu_tu`, `mo_ta`) VALUES
('CD', 'Cao đẳng', 5, 'Đào tạo trình độ cao đẳng'),
('DH', 'Đại học', 6, 'Đào tạo trình độ đại học và sau đại học'),
('MN', 'Mầm non', 1, 'Cấp học dành cho trẻ từ 3 tháng đến 6 tuổi'),
('TH', 'Tiểu học', 2, 'Cấp học từ lớp 1 đến lớp 5'),
('THCS', 'THCS', 3, 'Trung học cơ sở từ lớp 6 đến lớp 9'),
('THPT', 'THPT', 4, 'Trung học phổ thông từ lớp 10 đến lớp 12');

-- --------------------------------------------------------

--
-- Table structure for table `co_so_vat_chat`
--

CREATE TABLE `co_so_vat_chat` (
  `ma_co_so` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `loai_co_so` varchar(100) DEFAULT NULL,
  `so_luong` int DEFAULT '0',
  `dien_tich` decimal(10,2) DEFAULT NULL,
  `tinh_trang` varchar(50) DEFAULT NULL,
  `ghi_chu` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `co_so_vat_chat`
--

INSERT INTO `co_so_vat_chat` (`ma_co_so`, `ma_truong`, `loai_co_so`, `so_luong`, `dien_tich`, `tinh_trang`, `ghi_chu`) VALUES
(1, 'DHCT001', 'Phòng học', 500, 25000.00, 'Tốt', 'Phòng học đầy đủ thiết bị'),
(2, 'DHCT001', 'Phòng thí nghiệm', 50, 5000.00, 'Tốt', 'Phòng thí nghiệm hiện đại'),
(3, 'DHCT001', 'Thư viện', 1, 2000.00, 'Tốt', 'Thư viện với 500000 đầu sách'),
(4, 'DHCT001', 'Sân thể thao', 10, 15000.00, 'Tốt', 'Sân bóng đá, bóng rổ, tennis'),
(5, 'THPT001', 'Phòng học', 36, 1800.00, 'Tốt', 'Phòng học 50 chỗ'),
(6, 'THPT001', 'Phòng thí nghiệm', 6, 300.00, 'Tốt', 'Phòng thí nghiệm Lý, Hóa, Sinh'),
(7, 'THPT001', 'Thư viện', 1, 200.00, 'Tốt', 'Thư viện với 10000 đầu sách'),
(8, 'THPT001', 'Sân thể thao', 2, 1000.00, 'Tốt', 'Sân bóng đá và bóng rổ'),
(9, 'THCS001', 'Phòng học', 24, 1200.00, 'Tốt', 'Phòng học 35 chỗ'),
(10, 'THCS001', 'Phòng thí nghiệm', 3, 150.00, 'Tốt', 'Phòng thí nghiệm cơ bản'),
(11, 'THCS001', 'Thư viện', 1, 100.00, 'Tốt', 'Thư viện với 5000 đầu sách'),
(12, 'TH001', 'Phòng học', 30, 900.00, 'Tốt', 'Phòng học 35 chỗ'),
(13, 'TH001', 'Thư viện', 1, 80.00, 'Tốt', 'Thư viện với 3000 đầu sách'),
(14, 'TH001', 'Sân chơi', 1, 500.00, 'Tốt', 'Sân chơi cho học sinh tiểu học'),
(15, 'MN001', 'Phòng học', 12, 360.00, 'Tốt', 'Phòng học 25 chỗ'),
(16, 'MN001', 'Sân chơi', 1, 200.00, 'Tốt', 'Sân chơi an toàn cho trẻ mầm non');

-- --------------------------------------------------------

--
-- Table structure for table `lich_su_thay_doi`
--

CREATE TABLE `lich_su_thay_doi` (
  `ma_lich_su` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `loai_thay_doi` varchar(50) DEFAULT NULL,
  `noi_dung_thay_doi` varchar(1000) DEFAULT NULL,
  `nguoi_thay_doi` varchar(100) DEFAULT NULL,
  `ngay_thay_doi` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `lich_su_thay_doi`
--

INSERT INTO `lich_su_thay_doi` (`ma_lich_su`, `ma_truong`, `loai_thay_doi`, `noi_dung_thay_doi`, `nguoi_thay_doi`, `ngay_thay_doi`) VALUES
(1, 'DHCT001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 42000 lên 45000', 'Admin', '2025-10-09 03:07:06'),
(2, 'THPT001', 'Thay đổi địa chỉ', 'Cập nhật địa chỉ mới: 73 Mậu Thân, Ninh Kiều, Cần Thơ', 'Admin', '2025-10-09 03:07:06'),
(3, 'THCS001', 'Cập nhật số liệu', 'Cập nhật số lớp từ 22 lên 24', 'Admin', '2025-10-09 03:07:06'),
(4, 'TH001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 950 lên 1000', 'Admin', '2025-10-09 03:07:06'),
(5, 'MN001', 'Cập nhật số liệu', 'Cập nhật số học sinh từ 280 lên 300', 'Admin', '2025-10-09 03:07:06'),
(6, 'DHCT001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"3/2, Ninh Kiều, Cần Thơ\" thành \"Khu II, đường 3/2, phường Xuân Khánh, quận Ninh Kiều, thành phố Cần Thơ.\"', 'System', '2025-10-09 13:52:11'),
(7, 'CDCT001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"20/30 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ\" thành \"413 Đ. 30 Tháng 4, Hưng Lợi, Ninh Kiều, Cần Thơ 92000, Việt Nam\"', 'System', '2025-10-13 09:23:20'),
(8, 'CDCT002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"126 Nguyễn Thái Học, Ninh Kiều, Cần Thơ\" thành \"340 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:25:25'),
(9, 'CDCT003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"57 Nguyễn Văn Cừ, Bình Thủy, Cần Thơ\" thành \"9 Đ. Cách Mạng Tháng 8, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:45:44'),
(10, 'CDCT004', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"160 30/4, Ninh Kiều, Cần Thơ\" thành \"Bình Thuỷ, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:46:45'),
(11, 'CDCT005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"600 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ\" thành \"Toà nhà FPT Polytechnic, Đ. Số 22, Thường Thạnh, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:47:57'),
(12, 'CDCT006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ\" thành \"279aa Nguyễn Văn Cừ Nối Dài, An Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:49:52'),
(13, 'CDCT007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"57 Nguyễn Văn Cừ, Bình Thủy, Cần Thơ\" thành \"184, Phước Thới, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:51:27'),
(14, 'CDCT008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"160 30/4, Ninh Kiều, Cần Thơ\" thành \"Số 47 Đường số 1, KV3 Sông Hậu, cầu Cồn Khương, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:53:18'),
(15, 'CDCT010', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"160 30/4, Ninh Kiều, Cần Thơ\" thành \"41 Đ. Cách Mạng Tháng 8, Thới Bình, Ninh Kiều, Cần Thơ 94000, Việt Nam\"', 'System', '2025-10-13 09:55:57'),
(16, 'CDCT009', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"57 Đ. Cách Mạng Tháng 8, An Thới, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:57:42'),
(17, 'CDCT011', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"160 30/4, Ninh Kiều, Cần Thơ\" thành \"188/35A Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:59:04'),
(18, 'DHCT001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"Khu II, đường 3/2, phường Xuân Khánh, quận Ninh Kiều, thành phố Cần Thơ.\" thành \"Khu II, Đ. 3 Tháng 2, Xuân Khánh, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 09:59:54'),
(19, 'DHCT002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"179 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ\" thành \"179 Đ. Nguyễn Văn Cừ, P, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:00:49'),
(20, 'DHCT003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"68 Trần Chiên, Bình Thủy, Cần Thơ\" thành \"Trần Chiên/68 Phường, Khu vực Thạnh Mỹ, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:01:59'),
(21, 'DHCT004', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ\" thành \"168 Nguyễn Văn Cừ Nối Dài, An Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:03:05'),
(22, 'DHCT005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"600 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ\" thành \"600 Nguyễn Văn Cừ Nối Dài, An Bình, Bình Thủy, Cần Thơ 900000, Việt Nam\"', 'System', '2025-10-13 10:04:22'),
(23, 'DHCT006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"256 Nguyễn Văn Cừ, Ninh Kiều, Cần Thơ\" thành \"256 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ 900000, Việt Nam\"', 'System', '2025-10-13 10:06:32'),
(24, 'DHCT007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"160 30/4, Ninh Kiều, Cần Thơ\" thành \"160 Hẻm 42 Đ. 30/4, Xuân Khánh, Ninh Kiều, Cần Thơ 900000, Việt Nam\"', 'System', '2025-10-13 10:07:35'),
(25, 'DHCT008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"168 Nguyễn Văn Cừ, Cái Răng, Cần Thơ\" thành \"L1 D20, KHU DÂN CƯ ĐÔ THỊ MỚI HƯNG PHÚ, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:09:22'),
(26, 'MN001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"2QHM+2Q5, Hẻm 14 Nguyễn Thị Minh Khai, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:10:53'),
(27, 'MN002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"826B Đ. Bùi Hữu Nghĩa, Long Hoà, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:12:13'),
(28, 'MN003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"9 Đương Lê Hồng Phong, Bình Thuỷ, Bình Thủy, Cần Thơ 94000, Việt Nam\"', 'System', '2025-10-13 10:13:35'),
(29, 'MN004', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"07 Đ. Lý Thái Tổ, Hưng Phú, Cái Răng, Cần Thơ 90000, Việt Nam\"', 'System', '2025-10-13 10:14:57'),
(30, 'MN005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"4J6F+7M3, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:16:23'),
(31, 'MN006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"54 Sư Vạn Hạnh, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:17:30'),
(32, 'MN007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Phong Điền, Cần Thơ\" thành \"2M37+F4M, Phan Văn Trị, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:18:33'),
(33, 'THPT010', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"6CF2+V8F, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:20:16'),
(34, 'THCS010', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"508 QL80, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:25:18'),
(35, 'THPT020', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thới Lai, Cần Thơ\" thành \"3J75+F5V, Thới Lai, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:29:10'),
(36, 'THCS019', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thới Lai, Cần Thơ\" thành \"2G5J+2G2, Bốn Tổng - Một Ngàn, Trường Xuân, Thới Lai, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:31:46'),
(37, 'THPT003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"QL1A, An Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:33:30'),
(38, 'MN010', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thới Lai, Cần Thơ\" thành \"2JF7+PGW, Trường Thành, Thới Lai, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:35:07'),
(39, 'THCS015', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"Trường Chính Trị, Ba Láng, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:36:22'),
(40, 'TH005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"XRC6+6J3, Tân Phú, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:38:08'),
(41, 'THPT001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"Khu Nam Long, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 10:39:16'),
(42, 'MN008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"3CRJ+GCQ, ĐT921, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:24:00'),
(43, 'MN009', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"6CX7+8V7, Ấp Qui Long, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:25:42'),
(44, 'MN011', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"108 Đường Châu Văn Liêm, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:50:33'),
(45, 'MN012', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"Số 9b Đường Số 5, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:52:26'),
(46, 'MN013', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"73 Mậu Thân, Bình Thủy, Cần Thơ1103 QL91, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:54:33'),
(47, 'MN013', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ1103 QL91, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\" thành \"1103 QL91, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 11:54:42'),
(48, 'MN014', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"174 Đ. Trần Hưng Đạo, Thới Bình, Ninh Kiều, Cần Thơ 94000, Việt Nam\"', 'System', '2025-10-13 11:56:51'),
(49, 'MN015', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"Đ. Trần Việt Châu, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:00:20'),
(50, 'MN016', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"369 Đ. Nguyễn Văn Cừ, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:10:11'),
(51, 'TH001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"11 Đ. Nguyễn Khuyến, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:11:48'),
(52, 'TH002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"39 Đ. Số 6A, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:14:51'),
(53, 'TH003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"40 Đường mương khai, Phường Thới Long, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:18:31'),
(54, 'TH006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"3J4X+MG3, Trường Lạc, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:20:47'),
(55, 'TH007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"7GCJ+QVP, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:22:15'),
(56, 'TH008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Phong Điền, Cần Thơ\" thành \"XMWF+WCX, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:23:33'),
(57, 'TH009', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"4C3F+42G, ĐT919, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:24:35'),
(58, 'TH010', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"69JX+PG5, QL80, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:26:28'),
(59, 'TH011', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"4M56+F2G, Phước Thới, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:28:43'),
(60, 'TH012', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"9 Đ. Hoà Bình, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:30:22'),
(61, 'TH012', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"9 Đ. Hoà Bình, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\" thành \"Hẻm 50 Quang Trung, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:31:29'),
(62, 'TH013', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"24 Đ. Trần Hưng Đạo, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:32:38'),
(63, 'TH014', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"11 Đ. Nguyễn Khuyến, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:33:31'),
(64, 'TH015', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"976 Đ. Bùi Hữu Nghĩa, Long Tuyền, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:34:32'),
(65, 'TH017', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"5JC3+5RH, Khu Vực Thới Hòa 2, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:38:12'),
(66, 'TH018', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Phong Điền, Cần Thơ\" thành \"2M2G+QC8, DTLS Phan Văn Trị, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:39:41'),
(67, 'THCS001', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"63 Đ. 30 Tháng 4, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:40:46'),
(68, 'THCS002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"4M55+CW6, QL91, Phước Thới, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:42:23'),
(69, 'THCS003', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"36 Đ. Trần Bình Trọng, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:48:29'),
(70, 'THCS004', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"210 Đ. Bùi Hữu Nghĩa, Bình Thuỷ, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:49:53'),
(71, 'THCS005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"Trường Chính Trị, Ba Láng, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 12:51:08'),
(72, 'THCS006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"85 Đường 26 Tháng 3, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:06:50'),
(73, 'THCS007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"689 Đ. Lê Thị Tạo, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:08:32'),
(74, 'THCS008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Phong Điền, Cần Thơ\" thành \"Mỹ Khánh, Phong Điền, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:09:30'),
(75, 'THCS009', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"3CRJ+G3G, Ấp Thới Thuận, Cờ Đỏ, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:10:49'),
(76, 'THCS011', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"56 Đ. Ngô Quyền, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:12:40'),
(77, 'THCS012', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"355 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:13:49'),
(78, 'THCS013', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"148 Đ. Mậu Thân, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:18:45'),
(79, 'THCS014', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"62 Đương Lê Hồng Phong, Phường Trà An, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:21:38'),
(80, 'THCS014', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"62 Đương Lê Hồng Phong, Phường Trà An, Bình Thủy, Cần Thơ, Việt Nam\" thành \"3P6G+5V6, Long Hoà, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:41:10'),
(81, 'THCS015', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"Trường Chính Trị, Ba Láng, Cái Răng, Cần Thơ, Việt Nam\" thành \"2Q63+34X, QL1A, An Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:42:50'),
(82, 'THCS016', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"150 Đ. Thái Thị Hạnh, Phường Long Hưng, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:44:01'),
(83, 'THCS017', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"6HM2+PR8, Trung Kiên, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:45:18'),
(84, 'THCS018', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"22°03\'00. 104°39\'38., 3\"N Đ. Cách Mạng Tháng 8, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:47:56'),
(85, 'THCS020', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"7F57+CM3, Vĩnh Bình, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:50:51'),
(86, 'THPT002', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"Số 1 Đ. Xô Viết Nghệ Tĩnh, Tân An, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:51:45'),
(87, 'THPT004', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"3Q67+JC4, Đ. Cách Mạng Tháng 8, An Thới, Bình Thủy, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:53:00'),
(88, 'THPT005', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"7GP9+HRM, 62 QL91, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:53:56'),
(89, 'THPT006', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"33 Đ. Xô Viết Nghệ Tĩnh, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:55:50'),
(90, 'THPT007', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"177 Đ. Thái Thị Hạnh, Phường Long Hưng, Ô Môn, Cần Thơ 02923, Việt Nam\"', 'System', '2025-10-13 13:56:53'),
(91, 'THPT008', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thới Lai, Cần Thơ\" thành \"Ấp Thới Thuận A, Thới Lai, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 13:57:47'),
(92, 'THPT009', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"3CRM+3C3, Hà Huy Giáp, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:01:37'),
(93, 'THPT011', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"Khu 2 Đại học đường, 3/2, Xuân Khánh, Ninh Kiều, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:02:58'),
(94, 'THPT012', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ninh Kiều, Cần Thơ\" thành \"223 Đường Trần Hưng Đạo, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:04:10'),
(95, 'THPT013', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Bình Thủy, Cần Thơ\" thành \"161 Lê Bình, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:05:47'),
(96, 'THPT014', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cái Răng, Cần Thơ\" thành \"2Q5P+5HJ, Hưng Phú, Cái Răng, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:08:02'),
(97, 'THPT015', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Ô Môn, Cần Thơ\" thành \"13 Đường Trần Hưng Đạo, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:09:09'),
(98, 'THPT016', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Thốt Nốt, Cần Thơ\" thành \"Mai Văn Bộ, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:10:05'),
(99, 'THPT017', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Cờ Đỏ, Cần Thơ\" thành \"6G55+4GQ, ĐT921, Trung An, Thốt Nốt, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:11:06'),
(100, 'THPT018', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Phong Điền, Cần Thơ\" thành \"2M2H+F7X, ĐT923, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:12:40'),
(101, 'THPT019', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"73 Mậu Thân, Vĩnh Thạnh, Cần Thơ\" thành \"583F+WF2, Thị trấn Thanh An, Vĩnh Thạnh, Cần Thơ, Việt Nam\"', 'System', '2025-10-13 14:14:59'),
(102, 'THPT020', 'Thay đổi địa chỉ', 'Thay đổi địa chỉ từ \"3J75+F5V, Thới Lai, Cần Thơ, Việt Nam\" thành \"1A Đ. Xô Viết Nghệ Tĩnh, Thới Bình, Ninh Kiều, Cần Thơ 92000, Việt Nam\"', 'System', '2025-10-13 14:23:49');

-- --------------------------------------------------------

--
-- Table structure for table `loai_truong`
--

CREATE TABLE `loai_truong` (
  `ma_loai_truong` varchar(10) NOT NULL,
  `ten_loai_truong` varchar(50) NOT NULL,
  `mo_ta` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `loai_truong`
--

INSERT INTO `loai_truong` (`ma_loai_truong`, `ten_loai_truong`, `mo_ta`) VALUES
('CL', 'Công lập', 'Trường do nhà nước đầu tư và quản lý'),
('CV', 'Chuyên', 'Trường chuyên đào tạo học sinh năng khiếu'),
('LK', 'Liên kết', 'Trường liên kết với các đơn vị trong/ngoài nước'),
('QT', 'Quốc tế', 'Trường theo chương trình quốc tế'),
('TT', 'Tư thục', 'Trường tư nhân');

-- --------------------------------------------------------

--
-- Table structure for table `quan_huyen`
--

CREATE TABLE `quan_huyen` (
  `ma_quan_huyen` varchar(10) NOT NULL,
  `ten_quan_huyen` varchar(100) NOT NULL,
  `loai_don_vi` varchar(20) DEFAULT NULL,
  `toa_do_trung_tum` point DEFAULT NULL,
  `dien_tich` decimal(10,2) DEFAULT NULL,
  `dan_so` int DEFAULT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `quan_huyen`
--

INSERT INTO `quan_huyen` (`ma_quan_huyen`, `ten_quan_huyen`, `loai_don_vi`, `toa_do_trung_tum`, `dien_tich`, `dan_so`, `ghi_chu`) VALUES
('BT', 'Bình Thủy', 'Quận', 0x000000000101000000ea04341136705a40aa60545227202440, NULL, NULL, NULL),
('CD', 'Cờ Đỏ', 'Huyện', 0x000000000101000000295c8fc2f55c5a4061c3d32b65392440, NULL, NULL, NULL),
('CR', 'Cái Răng', 'Quận', 0x0000000001010000001ea7e8482e735a4043ad69de710a2440, NULL, NULL, NULL),
('NK', 'Ninh Kiều', 'Quận', 0x000000000101000000925cfe43fa715a401ac05b2041112440, NULL, NULL, NULL),
('OM', 'Ô Môn', 'Quận', 0x0000000001010000008126c286a7675a404e62105839342440, NULL, NULL, NULL),
('PD', 'Phong Điền', 'Huyện', 0x000000000101000000a1f831e6ae6d5a40b6847cd0b3592440, NULL, NULL, NULL),
('TL', 'Thới Lai', 'Huyện', 0x000000000101000000c286a757ca625a40933a014d840d2440, NULL, NULL, NULL),
('TN', 'Thốt Nốt', 'Quận', 0x0000000001010000001b0de02d90605a406a4df38e53942440, NULL, NULL, NULL),
('VT', 'Vĩnh Thạnh', 'Huyện', 0x000000000101000000c442ad69de655a40c74b378941e02340, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `thong_ke_truong_theo_cap_hoc`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_cap_hoc` (
`ma_cap_hoc` varchar(10)
,`ten_cap_hoc` varchar(50)
,`thu_tu` int
,`so_truong` bigint
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `thong_ke_truong_theo_loai`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_loai` (
`ma_loai_truong` varchar(10)
,`ten_loai_truong` varchar(50)
,`so_truong` bigint
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `thong_ke_truong_theo_quan_huyen`
-- (See below for the actual view)
--
CREATE TABLE `thong_ke_truong_theo_quan_huyen` (
`ma_quan_huyen` varchar(10)
,`ten_quan_huyen` varchar(100)
,`loai_don_vi` varchar(20)
,`so_truong` bigint
,`tong_hoc_sinh` decimal(32,0)
,`trung_binh_hoc_sinh` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Table structure for table `truong_da_cap`
--

CREATE TABLE `truong_da_cap` (
  `ma_truong_da_cap` int NOT NULL,
  `ma_truong` varchar(20) NOT NULL,
  `ma_cap_hoc` varchar(10) NOT NULL,
  `so_lop_cap_hoc` int DEFAULT '0',
  `so_hoc_sinh_cap_hoc` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `truong_da_cap`
--

INSERT INTO `truong_da_cap` (`ma_truong_da_cap`, `ma_truong`, `ma_cap_hoc`, `so_lop_cap_hoc`, `so_hoc_sinh_cap_hoc`) VALUES
(1, 'THPT001', 'THCS', 12, 400),
(2, 'THPT002', 'THCS', 15, 500),
(3, 'THPT003', 'THCS', 12, 400),
(4, 'THCS001', 'TH', 18, 600),
(5, 'THCS002', 'TH', 21, 700);

-- --------------------------------------------------------

--
-- Table structure for table `truong_hoc`
--

CREATE TABLE `truong_hoc` (
  `ma_truong` varchar(20) NOT NULL,
  `ten_truong` varchar(200) NOT NULL,
  `ma_cap_hoc` varchar(10) NOT NULL,
  `ma_loai_truong` varchar(10) NOT NULL,
  `ma_quan_huyen` varchar(10) NOT NULL,
  `dia_chi` varchar(300) DEFAULT NULL,
  `toa_do` point NOT NULL,
  `longitude` decimal(20,15) DEFAULT NULL,
  `latitude` decimal(20,15) DEFAULT NULL,
  `so_lop` int DEFAULT '0',
  `so_hoc_sinh` int DEFAULT '0',
  `dien_thoai` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `website` varchar(200) DEFAULT NULL,
  `nam_thanh_lap` int DEFAULT NULL,
  `dien_tich_khuon_vien` decimal(10,2) DEFAULT NULL,
  `trang_thai` varchar(20) DEFAULT 'Hoạt động',
  `ghi_chu` varchar(500) DEFAULT NULL,
  `ngay_tao` datetime DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `truong_hoc`
--

INSERT INTO `truong_hoc` (`ma_truong`, `ten_truong`, `ma_cap_hoc`, `ma_loai_truong`, `ma_quan_huyen`, `dia_chi`, `toa_do`, `longitude`, `latitude`, `so_lop`, `so_hoc_sinh`, `dien_thoai`, `email`, `website`, `nam_thanh_lap`, `dien_tich_khuon_vien`, `trang_thai`, `ghi_chu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
('CDCT001', 'Cao đẳng Cần Thơ', 'CD', 'CL', 'NK', '413 Đ. 30 Tháng 4, Hưng Lợi, Ninh Kiều, Cần Thơ 92000, Việt Nam', 0x000000000101000000530b5edcf2705a4047e7bbea4d072440, 105.764823047485420, 10.014266333997183, 0, 5000, '0292.3832663', 'cdct@ctu.edu.vn', 'www.cdct.edu.vn', 2006, 80000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT002', 'Cao đẳng Y tế Cần Thơ', 'CD', 'CL', 'NK', '340 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000002505d9a4f0705a4056c9fdefb8162440, 105.764687740262690, 10.044379710893434, 0, 3000, '0292.3820000', 'info@cdytct.edu.vn', 'www.cdytct.edu.vn', 2005, 40000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT003', 'Cao đẳng Kinh tế - Kỹ thuật Cần Thơ', 'CD', 'CL', 'BT', '9 Đ. Cách Mạng Tháng 8, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000126457d66b715a40b56e2522e31a2440, 105.772206864683800, 10.052514140195266, 0, 4000, '0292.3840000', 'info@cdktktct.edu.vn', 'www.cdktktct.edu.vn', 2007, 60000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT004', 'Cao đẳng Kinh tế Đối ngoại (Cơ sở Cần Thơ)', 'CD', 'CL', 'NK', 'Bình Thuỷ, Bình Thủy, Cần Thơ, Việt Nam', 0x00000000010100000066e0173fbd6e5a4049e2f645952d2440, 105.730300687138510, 10.089029489886473, 0, 2500, '0292.3840000', 'cantho@cof.edu.vn', 'cantho.cof.edu.vn', 2010, 30000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT005', 'Cao đẳng FPT Polytechnic (Cơ sở Cần Thơ)', 'CD', 'TT', 'NK', 'Toà nhà FPT Polytechnic, Đ. Số 22, Thường Thạnh, Cái Răng, Cần Thơ, Việt Nam', 0x000000000101000000e73f38cf87705a409141b5e4d7f62340, 105.758289151126160, 9.982115885854713, 0, 2000, '0292.7307307', 'cantho@fpt.edu.vn', 'cantho.poly.edu.vn', 2017, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT006', 'Cao đẳng Đại Việt Sài Gòn (Cơ sở Cần Thơ)', 'CD', 'TT', 'CR', '279aa Nguyễn Văn Cừ Nối Dài, An Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000035976e9baa6f5a401a8cb762c70b2440, 105.744788034437830, 10.023005566507027, 0, 1800, '0292.3840000', 'cantho@dvsg.edu.vn', 'cantho.dvsg.edu.vn', 2015, 20000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT007', 'Cao đẳng Cơ điện và Nông nghiệp Nam Bộ', 'CD', 'CL', 'OM', '184, Phước Thới, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000a21369ff8d6a5a40f384b5b138322440, 105.664916851629210, 10.098088792236444, 0, 2200, '0292.3840000', 'info@cdcennb.edu.vn', 'www.cdcennb.edu.vn', 2008, 35000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT008', 'Cao đẳng Du lịch Cần Thơ', 'CD', 'CL', 'NK', 'Số 47 Đường số 1, KV3 Sông Hậu, cầu Cồn Khương, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000003b6e5825a2715a40bfe735ec04202440, 105.775521599157330, 10.062537557201606, 0, 1500, '0292.3840000', 'info@cdtct.edu.vn', 'www.cdtct.edu.vn', 2009, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT009', 'Cao đẳng nghề Cần Thơ', 'CD', 'CL', 'BT', '57 Đ. Cách Mạng Tháng 8, An Thới, Bình Thủy, Cần Thơ, Việt Nam', 0x0000000001010000003a04c546cb705a4046b854eb2e202440, 105.762407009505210, 10.062857965556883, 0, 3000, '0292.3840000', 'info@cdnct.edu.vn', 'www.cdnct.edu.vn', 2005, 40000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT010', 'Cao đẳng Công thương Việt Nam', 'CD', 'TT', 'NK', '41 Đ. Cách Mạng Tháng 8, Thới Bình, Ninh Kiều, Cần Thơ 94000, Việt Nam', 0x000000000101000000ba485594bb715a40b5e61a5282182440, 105.777073939595450, 10.047869268211210, 0, 1200, '0292.3840000', 'cantho@ispace.edu.vn', 'cantho.ispace.edu.vn', 2016, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('CDCT011', 'Cao đẳng Văn hóa Nghệ thuật Cần Thơ', 'CD', 'CL', 'NK', '188/35A Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000007fd13d623715a40b711fb712c192440, 105.767812270660310, 10.049167215250106, 0, 1000, '0292.3840000', 'info@cdvhnact.edu.vn', 'www.cdvhnact.edu.vn', 2012, 20000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT001', 'Đại học Cần Thơ', 'DH', 'CL', 'NK', 'Khu II, Đ. 3 Tháng 2, Xuân Khánh, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000f8f6e2c352715a4098da2b53570f2440, 105.770676585812800, 10.029963111022240, 0, 45000, '02923832663', 'dhct@ctu.edu.vn', 'www.ctu.edu.vn', 1966, 1200000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT002', 'Đại học Y Dược Cần Thơ', 'DH', 'CL', 'NK', '179 Đ. Nguyễn Văn Cừ, P, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000fcccaf9f5c705a4087c571d8d5112440, 105.755653306656260, 10.034834636581548, 0, 12000, '0292.3739204', 'info@ctump.edu.vn', 'www.ctump.edu.vn', 2002, 150000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT003', 'Đại học Tây Đô', 'DH', 'TT', 'CR', 'Trần Chiên/68 Phường, Khu vực Thạnh Mỹ, Cái Răng, Cần Thơ, Việt Nam', 0x0000000001010000002b88957fa4705a40ac3c8c578aff2340, 105.760040184046990, 9.999102340573096, 0, 8000, '0292.3848888', 'info@tdu.edu.vn', 'www.tdu.edu.vn', 2001, 80000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT004', 'Đại học Nam Cần Thơ', 'DH', 'TT', 'NK', '168 Nguyễn Văn Cừ Nối Dài, An Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000838fa4d2446e5a40320e88b0eb032440, 105.722950611785600, 10.007657543762523, 0, 6000, '0292.3840000', 'info@nctu.edu.vn', 'www.nctu.edu.vn', 2006, 60000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT005', 'Đại học FPT Cần Thơ', 'DH', 'TT', 'BT', '600 Nguyễn Văn Cừ Nối Dài, An Bình, Bình Thủy, Cần Thơ 900000, Việt Nam', 0x000000000101000000637bf63ce16e5a409a93465e63062440, 105.732497444825230, 10.012476869693092, 0, 3000, '0292.7307307', 'cantho@fpt.edu.vn', 'cantho.fpt.edu.vn', 2016, 50000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT006', 'Đại học Kỹ thuật - Công nghệ Cần Thơ', 'DH', 'CL', 'NK', '256 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ 900000, Việt Nam', 0x0000000001010000008854f81527715a405a604e7b01182440, 105.768010609159430, 10.046886304204396, 0, 15000, '0292.3832663', 'info@ctut.edu.vn', 'www.ctut.edu.vn', 2006, 200000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT007', 'Đại học Greenwich (Cơ sở Cần Thơ)', 'DH', 'LK', 'NK', '160 Hẻm 42 Đ. 30/4, Xuân Khánh, Ninh Kiều, Cần Thơ 900000, Việt Nam', 0x000000000101000000a99694c9c5715a402a81fdefcd0e2440, 105.777696986299490, 10.028914928145770, 0, 2000, '0292.7307307', 'cantho@greenwich.edu.vn', 'cantho.greenwich.edu.vn', 2018, 30000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('DHCT008', 'Đại học Kiến trúc TP.HCM (Cơ sở Cần Thơ)', 'DH', 'CL', 'CR', 'L1 D20, KHU DÂN CƯ ĐÔ THỊ MỚI HƯNG PHÚ, Cái Răng, Cần Thơ, Việt Nam', 0x00000000010100000040f85429bc725a401ba711b5b5062440, 105.792734463670970, 10.013105066685560, 0, 1500, '0292.3840000', 'cantho@uah.edu.vn', 'cantho.uah.edu.vn', 2015, 25000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN001', 'Mầm non Hoa Hồng', 'MN', 'CL', 'NK', '2QHM+2Q5, Hẻm 14 Nguyễn Thị Minh Khai, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000001d0356b738725a404ff9e1fa1e0e2440, 105.784711679455040, 10.027580108723354, 12, 300, '0292.3820000', 'hoahong@edu.vn', 'www.hoahong.edu.vn', 1990, 2000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN002', 'Mầm non Hoa Sen', 'MN', 'CL', 'BT', '826B Đ. Bùi Hữu Nghĩa, Long Hoà, Bình Thủy, Cần Thơ, Việt Nam', 0x000000000101000000153a2623536e5a40fa80e470061b2440, 105.723824298220580, 10.052783515828640, 10, 250, '0292.3820000', 'hoasen@edu.vn', 'www.hoasen.edu.vn', 1992, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN003', 'Mầm non Bình Thủy', 'MN', 'CL', 'BT', '9 Đương Lê Hồng Phong, Bình Thuỷ, Bình Thủy, Cần Thơ 94000, Việt Nam', 0x000000000101000000e7637a0800705a40cc2851354e262440, 105.750002021333430, 10.074815431744717, 8, 200, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1993, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN004', ' ACA - Mầm non song ngữ', 'MN', 'CL', 'CR', '07 Đ. Lý Thái Tổ, Hưng Phú, Cái Răng, Cần Thơ 90000, Việt Nam', 0x00000000010100000070e5d8fe36725a404c0787dfc0092440, 105.784606658756960, 10.019049630387280, 8, 200, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1994, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN005', 'Mầm Non Hướng Dương', 'MN', 'CL', 'OM', '4J6F+7M3, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000b08e0809f3675a408f317353a6382440, 105.624208696705640, 10.110643966495244, 6, 150, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1995, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN006', 'Mầm non Thốt Nốt', 'MN', 'CL', 'TN', '54 Sư Vạn Hạnh, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam', 0x00000000010100000031bfbcc7e4615a404761a68820892440, 105.529588636706440, 10.267826338110025, 6, 150, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1996, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN007', 'Mầm non Phong Điền', 'MN', 'CL', 'PD', '2M37+F4M, Phan Văn Trị, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam', 0x0000000001010000006593cef0746a5a40d26acd5300022440, 105.663387490972650, 10.003908747506475, 6, 150, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1997, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN008', 'Mầm Non Thị Trấn Cờ Đỏ', 'MN', 'CL', 'CD', '3CRJ+GCQ, ĐT921, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam', 0x0000000001010000007a2bffe1985b5a40fcb62417ce2e2440, 105.431206225575720, 10.091416095001016, 6, 150, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1998, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN009', 'Mầm Non Thạnh Mỹ', 'MN', 'CL', 'VT', '6CX7+8V7, Ấp Qui Long, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x0000000001010000002fdf073c975a5a40bf25aa333d7f2440, 105.415480621039690, 10.248513807792618, 4, 100, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1999, 1000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN010', 'Mầm Non Trường Thành', 'MN', 'CL', 'TL', '2JF7+PGW, Trường Thành, Thới Lai, Cần Thơ, Việt Nam', 0x0000000001010000009c965b46b9675a40686d0e7e9c0e2440, 105.620683278505060, 10.028537692319063, 4, 100, '0292.3840000', 'thoilai@edu.vn', 'www.thoilai.edu.vn', 2000, 1000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN011', 'Mầm non Vành Khuyên', 'MN', 'CL', 'NK', '108 Đường Châu Văn Liêm, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000090adcda839725a4045df01dd30102440, 105.784769249780080, 10.031622797468694, 8, 200, '0292.3820000', 'vanhkhuyen@edu.vn', 'www.vanhkhuyen.edu.vn', 1995, 1500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN012', 'Mầm non Hồng Phát', 'MN', 'CL', 'NK', 'Số 9b Đường Số 5, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000c6f442fef16f5a400dd175c2ec0c2440, 105.749145093333110, 10.025243832475576, 6, 150, '0292.3820000', 'anbinh@edu.vn', 'www.anbinh.edu.vn', 1997, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN013', 'Mầm non Sao Mai', 'MN', 'CL', 'OM', '1103 QL91, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000aa55a4c3be675a407de8db8ccb372440, 105.621018324358970, 10.108974840015657, 6, 150, '0292.3840000', 'saomai@edu.vn', 'www.saomai.edu.vn', 1998, 1200.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN014', 'Mầm non Việt Mỹ', 'MN', 'TT', 'NK', '174 Đ. Trần Hưng Đạo, Thới Bình, Ninh Kiều, Cần Thơ 94000, Việt Nam', 0x00000000010100000029f64de8a4715a403210737a7c122440, 105.775690151342720, 10.036105944200333, 10, 250, '0292.3820000', 'vietmy@edu.vn', 'www.vietmy.edu.vn', 2005, 2000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN015', 'Mầm Non Việt Úc', 'MN', 'QT', 'NK', 'Đ. Trần Việt Châu, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000e3b9d4179a715a40d14596b841182440, 105.775030095806460, 10.047376411765898, 8, 200, '0292.3820000', 'iec@edu.vn', 'www.iec.edu.vn', 2010, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('MN016', 'Mầm Non Anh Đào', 'MN', 'QT', 'NK', '369 Đ. Nguyễn Văn Cừ, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000031015c8334705a403b140b5262102440, 105.753205146644870, 10.032000125744267, 8, 200, '0292.3820000', 'sis@edu.vn', 'www.sis.edu.vn', 2012, 1800.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH001', 'Tiểu học Ngô Quyền', 'TH', 'CL', 'NK', '11 Đ. Nguyễn Khuyến, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000483e429f2b725a40e69974c8be112440, 105.783912481966700, 10.034658683999577, 30, 1000, '0292.3820000', 'nguyenthaihoc@edu.vn', 'www.nguyenthaihoc.edu.vn', 1975, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH002', 'Tiểu Học Kim Đồng', 'TH', 'CL', 'NK', '39 Đ. Số 6A, An Khánh, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000046bb95f450705a4050bb2da05b132440, 105.754941126081660, 10.037808423597795, 27, 900, '0292.3820000', 'lehongphong@edu.vn', 'www.lehongphong.edu.vn', 1978, 5500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH003', 'Tiểu học Trần Phú', 'TH', 'CL', 'OM', '40 Đường mương khai, Phường Thới Long, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000b21f6ecc68655a40dfedfe441a592440, 105.584521396200930, 10.174028545493398, 24, 800, '0292.3820000', 'tranphu@edu.vn', 'www.tranphu.edu.vn', 1980, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH004', 'Tiểu học Bình Thủy', 'TH', 'CL', 'BT', '73 Mậu Thân, Bình Thủy, Cần Thơ', 0x0000000001010000000000000000705a40295c8fc2f5282440, 105.750000000000000, 10.080000000000000, 24, 800, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1982, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH005', 'Tiểu Học Tân Phú', 'TH', 'CL', 'CR', 'XRC6+6J3, Tân Phú, Cái Răng, Cần Thơ, Việt Nam', 0x0000000001010000009ae87650f9735a40f3013d3d06f12340, 105.812091938134840, 9.970750726411074, 21, 700, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1983, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH006', 'Tiểu học Nguyễn Tri Phương', 'TH', 'CL', 'OM', '3J4X+MG3, Trường Lạc, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000bcd524b987695a402c74dea4071d2440, 105.648908887836060, 10.056698944239620, 18, 600, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1985, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH007', 'Tiểu học Thốt Nốt 1', 'TH', 'CL', 'TN', '7GCJ+QVP, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam', 0x000000000101000000d995b58817625a407f6b17b9618b2440, 105.532686402635040, 10.272229942425609, 21, 700, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1984, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH008', 'Tiểu học Thị trấn Phong Điền', 'TH', 'CL', 'PD', 'XMWF+WCX, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam', 0x000000000101000000e5fed7ab276b5a40838fa097cbfe2340, 105.674296341832430, 9.997647035932237, 18, 600, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1986, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH009', 'Tiểu Học Thị Trấn Cờ Đỏ 1', 'TH', 'CL', 'CD', '4C3F+42G, ĐT919, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam', 0x000000000101000000cfecff86185b5a40478ec94cbc342440, 105.423372030188360, 10.102999114612556, 18, 600, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1987, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH010', 'Tiểu Học Thị Trấn Vĩnh Thạnh', 'TH', 'CL', 'VT', '69JX+PG5, QL80, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x000000000101000000f110048dce595a408b6f8b7e4b772440, 105.403231862994080, 10.232997850914918, 15, 500, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1988, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH011', 'Tiểu học Nguyễn Huệ', 'TH', 'CL', 'OM', '4M56+F2G, Phước Thới, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000cb732982466a5a408bdade6bbb372440, 105.660553493958260, 10.108851786569423, 24, 800, '0292.3820000', 'nguyenhue@edu.vn', 'www.nguyenhue.edu.vn', 1980, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH012', 'Tiểu học An Lạc', 'TH', 'CL', 'NK', 'Hẻm 50 Quang Trung, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000004250c0e82a725a408a1899e80b0e2440, 105.783868968778760, 10.027434605301341, 21, 700, '0292.3820000', 'chuvanan@edu.vn', 'www.chuvanan.edu.vn', 1982, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH013', 'Tiểu học An Nghiệp', 'TH', 'CL', 'NK', '24 Đ. Trần Hưng Đạo, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000c0720dac96715a40819707879f122440, 105.774821293957760, 10.036373347927794, 21, 700, '0292.3820000', 'annghiep@edu.vn', 'www.annghiep.edu.vn', 1984, 4500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH014', 'Tiểu học Ngô Quyền', 'TH', 'CL', 'NK', '11 Đ. Nguyễn Khuyến, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000009279a51f39725a400156cb42ec112440, 105.784736548992700, 10.035005652734073, 18, 600, '0292.3820000', 'ngoquyen@edu.vn', 'www.ngoquyen.edu.vn', 1986, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH015', 'Tiểu học Long Tuyền 2', 'TH', 'CL', 'BT', '976 Đ. Bùi Hữu Nghĩa, Long Tuyền, Bình Thủy, Cần Thơ, Việt Nam', 0x00000000010100000070c15a8e2f6e5a40062d865667172440, 105.721652592304740, 10.045710281256572, 18, 600, '0292.3840000', 'longtuyen@edu.vn', 'www.longtuyen.edu.vn', 1988, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH016', 'Tiểu học Hưng Phú 1', 'TH', 'CL', 'CR', '73 Mậu Thân, Cái Răng, Cần Thơ', 0x000000000101000000413d4e4c66725a40104e2c07b8082440, 105.787493778615510, 10.017029022367780, 18, 600, '0292.3840000', 'hungphu@edu.vn', 'www.hungphu.edu.vn', 1990, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH017', 'Tiểu Học Thới Thuận 2', 'TH', 'CL', 'OM', '5JC3+5RH, Khu Vực Thới Hòa 2, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000f21a6d6106675a40ff0b9b8252582440, 105.609764439151860, 10.172504502703303, 15, 500, '0292.3840000', 'thoihoa@edu.vn', 'www.thoihoa.edu.vn', 1992, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('TH018', 'Tiểu Học Thạnh Phú Đông', 'TH', 'CL', 'PD', '2M2G+QC8, DTLS Phan Văn Trị, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam', 0x0000000001010000006b0832b8786b5a40052c832083012440, 105.679243134365310, 10.002953544628335, 15, 500, '0292.3840000', 'nhonai@edu.vn', 'www.nhonai.edu.vn', 1994, 3500.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS001', 'THCS Nguyễn Du', 'THCS', 'CL', 'NK', '63 Đ. 30 Tháng 4, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000085edee3e90705a4014b77dc0f4052440, 105.758804066970770, 10.011632933946693, 24, 800, '0292.3820000', 'nguyendu@edu.vn', 'www.nguyendu.edu.vn', 1980, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS002', 'THCS Lê Lợi', 'THCS', 'CL', 'OM', '4M55+CW6, QL91, Phước Thới, Ô Môn, Cần Thơ, Việt Nam', 0x0000000001010000004ba39493916a5a40b67cce62bb382440, 105.665135283617180, 10.110804641443206, 27, 900, '0292.3820000', 'leloi@edu.vn', 'www.leloi.edu.vn', 1978, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS003', 'THCS Trần Hưng Đạo', 'THCS', 'CL', 'NK', '36 Đ. Trần Bình Trọng, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000f412a16dc1715a4087e37134d6112440, 105.777430922793260, 10.034837378408850, 24, 800, '0292.3820000', 'tranhungdao@edu.vn', 'www.tranhungdao.edu.vn', 1982, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS004', 'THCS Bình Thủy', 'THCS', 'CL', 'BT', '210 Đ. Bùi Hữu Nghĩa, Bình Thuỷ, Bình Thủy, Cần Thơ, Việt Nam', 0x000000000101000000336a44a7da6f5a40eb92f7218d212440, 105.747720543681500, 10.065529881926940, 21, 700, '0292.3840000', 'binhthuy@edu.vn', 'www.binhthuy.edu.vn', 1985, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS005', 'THCS Lê Bình', 'THCS', 'CL', 'CR', 'Trường Chính Trị, Ba Láng, Cái Răng, Cần Thơ, Việt Nam', 0x000000000101000000eb30749ed76f5a403743f5ac79fc2340, 105.747535336940630, 9.993115811290052, 24, 800, '0292.3840000', 'cairang@edu.vn', 'www.cairang.edu.vn', 1983, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS006', 'THCS Châu Văn Liêm', 'THCS', 'CL', 'OM', '85 Đường 26 Tháng 3, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam', 0x0000000001010000003348e964af675a40b04b24d4fd382440, 105.620080211462480, 10.111311559134123, 18, 600, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1987, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS007', 'THCS Thốt Nốt', 'THCS', 'CL', 'TN', '689 Đ. Lê Thị Tạo, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam', 0x00000000010100000077cbaa30fc615a40693a57e75c8c2440, 105.531017462531840, 10.274146298788041, 21, 700, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1986, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS008', 'THCS Thị Trấn Phong Điền', 'THCS', 'CL', 'PD', 'Mỹ Khánh, Phong Điền, Cần Thơ, Việt Nam', 0x000000000101000000d68003647c6b5a40a91feb8a27fe2340, 105.679467204495580, 9.996395436479206, 18, 600, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1988, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS009', 'THCS Thị trấn Cờ Đỏ', 'THCS', 'CL', 'CD', '3CRJ+G3G, Ấp Thới Thuận, Cờ Đỏ, Cần Thơ, Việt Nam', 0x000000000101000000d4f980428e5b5a4043fb8c3ee02e2440, 105.430557847931880, 10.091554598531394, 18, 600, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1989, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS010', 'THCS Thị Trấn Vĩnh Thạnh', 'THCS', 'CL', 'VT', '508 QL80, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x0000000001010000005bd44f5abc585a40425b3ae206712440, 105.386496141394150, 10.220755643485635, 15, 500, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1990, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS011', 'THCS Đoàn Thị Điểm', 'THCS', 'CL', 'NK', '56 Đ. Ngô Quyền, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x00000000010100000085586c9039725a40f9a883874d122440, 105.784763437086510, 10.035747752019676, 21, 700, '0292.3820000', 'doanthidiem@edu.vn', 'www.doanthidiem.edu.vn', 1985, 7000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS012', 'THCS An Hòa 1', 'THCS', 'CL', 'NK', '355 Đ. Nguyễn Văn Cừ, An Hoà, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000d3b7009e1d715a40bea1de5004172440, 105.767432690335500, 10.044954802681670, 18, 600, '0292.3820000', 'anhoa@edu.vn', 'www.anhoa.edu.vn', 1987, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS013', 'THCS Huỳnh Thúc Kháng', 'THCS', 'CL', 'NK', '148 Đ. Mậu Thân, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000007cf64de95c715a40ae40c44091132440, 105.771295858512470, 10.038217567402480, 18, 600, '0292.3820000', 'huynhthuckhang@edu.vn', 'www.huynhthuckhang.edu.vn', 1989, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS014', 'THCS Long Hoà', 'THCS', 'CL', 'BT', '3P6G+5V6, Long Hoà, Bình Thủy, Cần Thơ, Việt Nam', 0x000000000101000000200493b3896e5a4020706a4cee1e2440, 105.727154630251330, 10.060411823265952, 18, 600, '0292.3840000', 'daosontay@edu.vn', 'www.daosontay.edu.vn', 1990, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS015', 'THCS Trần Ngọc Quế', 'THCS', 'CL', 'NK', '2Q63+34X, QL1A, An Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x0000000001010000009f43c7762f705a407c210f8840052440, 105.752896971315280, 10.010257961127301, 18, 600, '0292.3840000', 'lebinh@edu.vn', 'www.lebinh.edu.vn', 1991, 6000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS016', 'THCS Thới Long', 'THCS', 'CL', 'OM', '150 Đ. Thái Thị Hạnh, Phường Long Hưng, Ô Môn, Cần Thơ, Việt Nam', 0x0000000001010000007bae9bcc98655a40ee0f0db398552440, 105.587451126129890, 10.167180629105100, 15, 500, '0292.3840000', 'thoilong@edu.vn', 'www.thoilong.edu.vn', 1992, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS017', 'THCS Trung Kiên', 'THCS', 'CL', 'TN', '6HM2+PR8, Trung Kiên, Thốt Nốt, Cần Thơ, Việt Nam', 0x0000000001010000008260e72455635a40fd95807cf3772440, 105.552071786836700, 10.234279528328438, 15, 500, '0292.3840000', 'trungkien@edu.vn', 'www.trungkien.edu.vn', 1993, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS018', 'THCS Trúc Lâu', 'THCS', 'CL', 'NK', '22°03\'00. 104°39\'38., 3\"N Đ. Cách Mạng Tháng 8, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000cc262a5e68705a4097d95dcde6222440, 105.756370106853130, 10.068167131143850, 15, 500, '0292.3840000', 'thoidong@edu.vn', 'www.thoidong.edu.vn', 1994, 5000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS019', 'THCS Trường Xuân', 'THCS', 'CL', 'TL', '2G5J+2G2, Bốn Tổng - Một Ngàn, Trường Xuân, Thới Lai, Cần Thơ, Việt Nam', 0x000000000101000000fac49f2100625a40be4e1c80d9032440, 105.531258016610000, 10.007518771605984, 12, 400, '0292.3840000', 'tanthanh@edu.vn', 'www.tanthanh.edu.vn', 1995, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THCS020', 'THCS Vĩnh Bình', 'THCS', 'CL', 'VT', '7F57+CM3, Vĩnh Bình, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x000000000101000000ff493ed7b45d5a40e7addcf35c842440, 105.464162646130700, 10.258521671951668, 12, 400, '0292.3840000', 'vinhbinh@edu.vn', 'www.vinhbinh.edu.vn', 1996, 4000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT001', 'THPT Chuyên Lý Tự Trọng', 'THPT', 'CV', 'CR', 'Khu Nam Long, Cái Răng, Cần Thơ, Việt Nam', 0x000000000101000000f3e4794570725a40e1cd60cb7d002440, 105.788102501904900, 10.000959735457345, 36, 1200, '0292.3820000', 'lytutrong@edu.vn', 'www.lytutrong.edu.vn', 1985, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT002', 'THPT Châu Văn Liêm', 'THPT', 'CL', 'NK', 'Số 1 Đ. Xô Viết Nghệ Tĩnh, Tân An, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000e01f9bf22f725a408b3eb1d1b8122440, 105.784176494110850, 10.036566307913082, 42, 1500, '0292.3820000', 'chauvanliem@edu.vn', 'www.chauvanliem.edu.vn', 1975, 18000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT003', 'THPT Nguyễn Việt Hồng', 'THPT', 'CL', 'NK', 'QL1A, An Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000d876966e2b705a404f25b1921e062440, 105.752650877893190, 10.011952003597484, 39, 1350, '0292.3820000', 'nguyenvietdong@edu.vn', 'www.nguyenvietdong.edu.vn', 1980, 16000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT004', 'THPT Bùi Hữu Nghĩa', 'THPT', 'CL', 'BT', '3Q67+JC4, Đ. Cách Mạng Tháng 8, An Thới, Bình Thủy, Cần Thơ, Việt Nam', 0x00000000010100000022adf968de705a40c8cda9537f1f2440, 105.763574832748900, 10.061518301465995, 36, 1200, '0292.3840000', 'buihuunghia@edu.vn', 'www.buihuunghia.edu.vn', 1982, 14000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT005', 'THPT Thốt Nốt', 'THPT', 'CL', 'TN', '7GP9+HRM, 62 QL91, TT. Thốt Nốt, Thốt Nốt, Cần Thơ, Việt Nam', 0x0000000001010000000801620f4a615a40399741ec08932440, 105.520145269114550, 10.287177451140098, 33, 1100, '0292.3840000', 'thotnot@edu.vn', 'www.thotnot.edu.vn', 1990, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT006', 'THPT Phan Ngọc Hiển', 'THPT', 'CL', 'NK', '33 Đ. Xô Viết Nghệ Tĩnh, Thới Bình, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000e769b55826725a4050dfd632b4132440, 105.783590485727120, 10.038484181146174, 36, 1200, '0292.3840000', 'phanngoctong@edu.vn', 'www.phanngoctong.edu.vn', 1988, 15000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT007', 'THPT Thới Long', 'THPT', 'CL', 'OM', '177 Đ. Thái Thị Hạnh, Phường Long Hưng, Ô Môn, Cần Thơ 02923, Việt Nam', 0x00000000010100000011670fc295655a409d870a3059572440, 105.587265505830390, 10.170602322850579, 30, 1000, '0292.3840000', 'omon@edu.vn', 'www.omon.edu.vn', 1992, 11000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT008', 'THPT Thới Lai', 'THPT', 'CL', 'TL', 'Ấp Thới Thuận A, Thới Lai, Cần Thơ, Việt Nam', 0x0000000001010000008483558dad635a40218bb3ba231e2440, 105.557467778691770, 10.058866342942169, 27, 900, '0292.3840000', 'thoilai@edu.vn', 'www.thoilai.edu.vn', 1995, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT009', 'THPT Hà Huy Giáp', 'THPT', 'CL', 'CD', '3CRM+3C3, Hà Huy Giáp, TT. Cờ Đỏ, Cờ Đỏ, Cần Thơ, Việt Nam', 0x0000000001010000008158f7d4b95b5a4085f89870c92d2440, 105.433217279003670, 10.089427488969031, 30, 1000, '0292.3840000', 'codo@edu.vn', 'www.codo.edu.vn', 1993, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT010', 'THPT Vĩnh Thạnh', 'THPT', 'CL', 'VT', '6CF2+V8F, Thị trấn Vĩnh Thạnh, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x00000000010100000008f03bc5a6595a40985e8c040d732440, 105.400803860218840, 10.224708692679357, 24, 800, '0292.3840000', 'vinhthanh@edu.vn', 'www.vinhthanh.edu.vn', 1996, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT011', 'THPT Thực hành Sư phạm (ĐHCT)', 'THPT', 'CL', 'NK', 'Khu 2 Đại học đường, 3/2, Xuân Khánh, Ninh Kiều, Cần Thơ, Việt Nam', 0x000000000101000000d9abd95329715a40f5c9c8fb450e2440, 105.768147432870490, 10.027877681980480, 30, 1000, '0292.3820000', 'thsp@ctu.edu.vn', 'thsp.ctu.edu.vn', 1990, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT012', 'THPT Lương Định Của', 'THPT', 'CL', 'OM', '223 Đường Trần Hưng Đạo, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam', 0x000000000101000000102b6a5e21685a40bc8d116d913c2440, 105.627036670379540, 10.118297012703685, 27, 900, '0292.3820000', 'luongdinhcua@edu.vn', 'www.luongdinhcua.edu.vn', 1988, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT013', 'THPT Nguyễn Việt Dũng', 'THPT', 'CL', 'CR', '161 Lê Bình, Cái Răng, Cần Thơ, Việt Nam', 0x00000000010100000010d8553171705a4023b843a3e7fe2340, 105.756908735115080, 9.997861005798830, 33, 1100, '0292.3840000', 'nguyentrai@edu.vn', 'www.nguyentrai.edu.vn', 1985, 13000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT014', 'Phổ Thông Việt Hoa\n', 'THPT', 'CL', 'CR', '2Q5P+5HJ, Hưng Phú, Cái Răng, Cần Thơ, Việt Nam', 0x000000000101000000a67cd41b54725a4072b68c0614042440, 105.786383588320490, 10.007965283085671, 30, 1000, '0292.3840000', 'hoanghoatham@edu.vn', 'www.hoanghoatham.edu.vn', 1987, 12000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT015', 'THPT Lưu Hữu Phước', 'THPT', 'CL', 'OM', '13 Đường Trần Hưng Đạo, Châu Văn Liêm, Ô Môn, Cần Thơ, Việt Nam', 0x0000000001010000002da43a50cf685a40580cca7f8d3b2440, 105.637653405444060, 10.116313928045358, 27, 900, '0292.3840000', 'luuhuuphuoc@edu.vn', 'www.luuhuuphuoc.edu.vn', 1989, 11000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT016', 'THPT Thuận Hưng', 'THPT', 'CL', 'TN', 'Mai Văn Bộ, Thốt Nốt, Cần Thơ, Việt Nam', 0x000000000101000000112a3b6d90635a405348c24b786f2440, 105.555690105226190, 10.217714660135390, 24, 800, '0292.3840000', 'thuanhung@edu.vn', 'www.thuanhung.edu.vn', 1991, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT017', 'THPT Trung An', 'THPT', 'CL', 'TN', '6G55+4GQ, ĐT921, Trung An, Thốt Nốt, Cần Thơ, Việt Nam', 0x00000000010100000059a921fd90605a40e2f6870a6b6a2440, 105.508849413750240, 10.207847909066405, 24, 800, '0292.3840000', 'trungan@edu.vn', 'www.trungan.edu.vn', 1992, 10000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT018', 'THPT Phan Văn Trị', 'THPT', 'CL', 'PD', '2M2H+F7X, ĐT923, Thị trấn Phong Điền, Phong Điền, Cần Thơ, Việt Nam', 0x0000000001010000001a65064e686b5a4043497519a3002440, 105.678241258854910, 10.001244350020562, 21, 700, '0292.3840000', 'phongdien@edu.vn', 'www.phongdien.edu.vn', 1993, 9000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT019', 'THPT Thạnh An', 'THPT', 'CL', 'VT', '583F+WF2, Thị trấn Thanh An, Vĩnh Thạnh, Cần Thơ, Việt Nam', 0x000000000101000000aa771282b6545a401ef1b06a3e4f2440, 105.323639410051920, 10.154773077105855, 18, 600, '0292.3840000', 'thanhan@edu.vn', 'www.thanhan.edu.vn', 1994, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35'),
('THPT020', 'Trường Phổ thông Thái Bình Dương', 'THPT', 'CL', 'NK', '1A Đ. Xô Viết Nghệ Tĩnh, Thới Bình, Ninh Kiều, Cần Thơ 92000, Việt Nam', 0x0000000001010000001600539f35725a40a50db14038132440, 105.784522849135410, 10.037538549054100, 18, 600, '0292.3840000', 'dinhmon@edu.vn', 'www.dinhmon.edu.vn', 1995, 8000.00, 'Hoạt động', NULL, '2025-10-09 03:07:06', '2025-10-13 14:24:35');

--
-- Triggers `truong_hoc`
--
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_log_change` AFTER UPDATE ON `truong_hoc` FOR EACH ROW BEGIN
    IF OLD.so_hoc_sinh != NEW.so_hoc_sinh THEN
        INSERT INTO lich_su_thay_doi (ma_truong, loai_thay_doi, noi_dung_thay_doi, nguoi_thay_doi)
        VALUES (NEW.ma_truong, 'Cập nhật số liệu', 
                CONCAT('Cập nhật số học sinh từ ', OLD.so_hoc_sinh, ' lên ', NEW.so_hoc_sinh), 
                'System');
    END IF;
    
    IF OLD.dia_chi != NEW.dia_chi THEN
        INSERT INTO lich_su_thay_doi (ma_truong, loai_thay_doi, noi_dung_thay_doi, nguoi_thay_doi)
        VALUES (NEW.ma_truong, 'Thay đổi địa chỉ', 
                CONCAT('Thay đổi địa chỉ từ "', OLD.dia_chi, '" thành "', NEW.dia_chi, '"'), 
                'System');
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_sync_point_on_insert` BEFORE INSERT ON `truong_hoc` FOR EACH ROW BEGIN
  IF NEW.longitude IS NOT NULL AND NEW.latitude IS NOT NULL THEN
    SET NEW.toa_do = ST_SRID(POINT(NEW.longitude, NEW.latitude), 4326);
  ELSEIF NEW.toa_do IS NOT NULL THEN
    SET NEW.longitude = ST_X(NEW.toa_do);
    SET NEW.latitude  = ST_Y(NEW.toa_do);
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_sync_point_on_update_full` BEFORE UPDATE ON `truong_hoc` FOR EACH ROW BEGIN
  IF (NEW.longitude <=> OLD.longitude) = 0 OR (NEW.latitude <=> OLD.latitude) = 0 THEN
    IF NEW.longitude IS NOT NULL AND NEW.latitude IS NOT NULL THEN
      SET NEW.toa_do = ST_SRID(POINT(NEW.longitude, NEW.latitude), 4326);
    END IF;
  ELSEIF (ST_X(NEW.toa_do) <> ST_X(OLD.toa_do)) OR (ST_Y(NEW.toa_do) <> ST_Y(OLD.toa_do)) THEN
    SET NEW.longitude = ST_X(NEW.toa_do);
    SET NEW.latitude  = ST_Y(NEW.toa_do);
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_truong_hoc_update` BEFORE UPDATE ON `truong_hoc` FOR EACH ROW BEGIN
    SET NEW.ngay_cap_nhat = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `thong_ke_truong_theo_cap_hoc`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_cap_hoc`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_cap_hoc`  AS SELECT `ch`.`ma_cap_hoc` AS `ma_cap_hoc`, `ch`.`ten_cap_hoc` AS `ten_cap_hoc`, `ch`.`thu_tu` AS `thu_tu`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`cap_hoc` `ch` left join `truong_hoc` `th` on((`ch`.`ma_cap_hoc` = `th`.`ma_cap_hoc`))) GROUP BY `ch`.`ma_cap_hoc`, `ch`.`ten_cap_hoc`, `ch`.`thu_tu` ORDER BY `ch`.`thu_tu` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `thong_ke_truong_theo_loai`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_loai`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_loai`  AS SELECT `lt`.`ma_loai_truong` AS `ma_loai_truong`, `lt`.`ten_loai_truong` AS `ten_loai_truong`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`loai_truong` `lt` left join `truong_hoc` `th` on((`lt`.`ma_loai_truong` = `th`.`ma_loai_truong`))) GROUP BY `lt`.`ma_loai_truong`, `lt`.`ten_loai_truong` ;

-- --------------------------------------------------------

--
-- Structure for view `thong_ke_truong_theo_quan_huyen`
--
DROP TABLE IF EXISTS `thong_ke_truong_theo_quan_huyen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `thong_ke_truong_theo_quan_huyen`  AS SELECT `qh`.`ma_quan_huyen` AS `ma_quan_huyen`, `qh`.`ten_quan_huyen` AS `ten_quan_huyen`, `qh`.`loai_don_vi` AS `loai_don_vi`, count(`th`.`ma_truong`) AS `so_truong`, sum(`th`.`so_hoc_sinh`) AS `tong_hoc_sinh`, avg(`th`.`so_hoc_sinh`) AS `trung_binh_hoc_sinh` FROM (`quan_huyen` `qh` left join `truong_hoc` `th` on((`qh`.`ma_quan_huyen` = `th`.`ma_quan_huyen`))) GROUP BY `qh`.`ma_quan_huyen`, `qh`.`ten_quan_huyen`, `qh`.`loai_don_vi` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cap_hoc`
--
ALTER TABLE `cap_hoc`
  ADD PRIMARY KEY (`ma_cap_hoc`),
  ADD UNIQUE KEY `ten_cap_hoc` (`ten_cap_hoc`);

--
-- Indexes for table `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  ADD PRIMARY KEY (`ma_co_so`),
  ADD KEY `idx_co_so_ma_truong` (`ma_truong`),
  ADD KEY `idx_co_so_loai` (`loai_co_so`);

--
-- Indexes for table `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  ADD PRIMARY KEY (`ma_lich_su`),
  ADD KEY `idx_lich_su_ma_truong` (`ma_truong`),
  ADD KEY `idx_lich_su_ngay_thay_doi` (`ngay_thay_doi`);

--
-- Indexes for table `loai_truong`
--
ALTER TABLE `loai_truong`
  ADD PRIMARY KEY (`ma_loai_truong`);

--
-- Indexes for table `quan_huyen`
--
ALTER TABLE `quan_huyen`
  ADD PRIMARY KEY (`ma_quan_huyen`);

--
-- Indexes for table `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  ADD PRIMARY KEY (`ma_truong_da_cap`),
  ADD UNIQUE KEY `ma_truong` (`ma_truong`,`ma_cap_hoc`),
  ADD KEY `ma_cap_hoc` (`ma_cap_hoc`);

--
-- Indexes for table `truong_hoc`
--
ALTER TABLE `truong_hoc`
  ADD PRIMARY KEY (`ma_truong`),
  ADD KEY `idx_truong_hoc_cap_hoc` (`ma_cap_hoc`),
  ADD KEY `idx_truong_hoc_quan_huyen` (`ma_quan_huyen`),
  ADD KEY `idx_truong_hoc_loai_truong` (`ma_loai_truong`),
  ADD KEY `idx_truong_hoc_so_hoc_sinh` (`so_hoc_sinh`),
  ADD KEY `idx_truong_hoc_trang_thai` (`trang_thai`),
  ADD KEY `idx_truong_cap_hoc` (`ma_cap_hoc`),
  ADD KEY `idx_truong_loai` (`ma_loai_truong`),
  ADD KEY `idx_truong_quan_huyen` (`ma_quan_huyen`),
  ADD KEY `idx_truong_trang_thai` (`trang_thai`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  MODIFY `ma_co_so` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  MODIFY `ma_lich_su` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  MODIFY `ma_truong_da_cap` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `co_so_vat_chat`
--
ALTER TABLE `co_so_vat_chat`
  ADD CONSTRAINT `co_so_vat_chat_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`);

--
-- Constraints for table `lich_su_thay_doi`
--
ALTER TABLE `lich_su_thay_doi`
  ADD CONSTRAINT `lich_su_thay_doi_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`);

--
-- Constraints for table `truong_da_cap`
--
ALTER TABLE `truong_da_cap`
  ADD CONSTRAINT `truong_da_cap_ibfk_1` FOREIGN KEY (`ma_truong`) REFERENCES `truong_hoc` (`ma_truong`),
  ADD CONSTRAINT `truong_da_cap_ibfk_2` FOREIGN KEY (`ma_cap_hoc`) REFERENCES `cap_hoc` (`ma_cap_hoc`);

--
-- Constraints for table `truong_hoc`
--
ALTER TABLE `truong_hoc`
  ADD CONSTRAINT `truong_hoc_ibfk_1` FOREIGN KEY (`ma_cap_hoc`) REFERENCES `cap_hoc` (`ma_cap_hoc`),
  ADD CONSTRAINT `truong_hoc_ibfk_2` FOREIGN KEY (`ma_loai_truong`) REFERENCES `loai_truong` (`ma_loai_truong`),
  ADD CONSTRAINT `truong_hoc_ibfk_3` FOREIGN KEY (`ma_quan_huyen`) REFERENCES `quan_huyen` (`ma_quan_huyen`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
