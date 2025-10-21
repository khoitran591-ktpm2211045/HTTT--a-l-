<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? $_POST['action'] ?? '';

switch ($action) {
    case 'get_all':
        getAllSchools();
        break;
    case 'get_by_level':
        getSchoolsByLevel();
        break;
    case 'search_by_students':
        searchSchoolsByStudents();
        break;
    case 'get_statistics':
        getStatistics();
        break;
    case 'get_district_stats':
        getDistrictStats();
        break;
    case 'add_school':
        addSchool();
        break;
    case 'validate_coordinates':
        validateCoordinates();
        break;
    case 'update':
    case 'update_school':
        updateSchool();
        break;
    case 'update_position':
        updateSchoolPosition();
        break;
    case 'delete_school':
        deleteSchool();
        break;
    default:
        http_response_code(400);
        echo json_encode(['error' => 'Action không hợp lệ']);
        break;
}

function getAllSchools() {
    global $pdo;
    
    try {
        $sql = "SELECT 
                    t.ma_truong as id,
                    t.ten_truong,
                    t.ma_cap_hoc,
                    c.ten_cap_hoc,
                    t.ma_loai_truong,
                    l.ten_loai_truong,
                    t.ma_quan_huyen,
                    q.ten_quan_huyen,
                    t.dia_chi,
                    ST_X(t.toa_do) as longitude,
                    ST_Y(t.toa_do) as latitude,
                    t.so_lop,
                    t.so_hoc_sinh,
                    t.dien_thoai,
                    t.email,
                    t.website,
                    t.nam_thanh_lap,
                    t.dien_tich_khuon_vien,
                    t.trang_thai
                FROM truong_hoc t
                JOIN cap_hoc c ON t.ma_cap_hoc = c.ma_cap_hoc
                JOIN loai_truong l ON t.ma_loai_truong = l.ma_loai_truong
                JOIN quan_huyen q ON t.ma_quan_huyen = q.ma_quan_huyen
                WHERE t.trang_thai = 'Hoạt động'
                ORDER BY t.ten_truong";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $schools = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $schools,
            'total' => count($schools)
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi truy vấn database: ' . $e->getMessage()]);
    }
}

function getSchoolsByLevel() {
    global $pdo;
    
    $level = $_GET['level'] ?? '';
    
    if (empty($level)) {
        http_response_code(400);
        echo json_encode(['error' => 'Thiếu tham số level']);
        return;
    }
    
    try {
        $sql = "SELECT 
                    t.ma_truong,
                    t.ten_truong,
                    t.ma_cap_hoc,
                    c.ten_cap_hoc,
                    t.ma_loai_truong,
                    l.ten_loai_truong,
                    t.ma_quan_huyen,
                    q.ten_quan_huyen,
                    t.dia_chi,
                    ST_X(t.toa_do) as longitude,
                    ST_Y(t.toa_do) as latitude,
                    t.so_lop,
                    t.so_hoc_sinh,
                    t.dien_thoai,
                    t.email,
                    t.website,
                    t.nam_thanh_lap,
                    t.dien_tich_khuon_vien,
                    t.trang_thai
                FROM truong_hoc t
                JOIN cap_hoc c ON t.ma_cap_hoc = c.ma_cap_hoc
                JOIN loai_truong l ON t.ma_loai_truong = l.ma_loai_truong
                JOIN quan_huyen q ON t.ma_quan_huyen = q.ma_quan_huyen
                WHERE t.ma_cap_hoc = ? AND t.trang_thai = 'Hoạt động'
                ORDER BY t.ten_truong";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$level]);
        $schools = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $schools,
            'total' => count($schools)
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi truy vấn database: ' . $e->getMessage()]);
    }
}

function searchSchoolsByStudents() {
    global $pdo;
    
    $minStudents = $_GET['min_students'] ?? 0;
    
    if (!is_numeric($minStudents) || $minStudents < 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Số học sinh phải là số dương']);
        return;
    }
    
    try {
        $sql = "SELECT 
                    t.ma_truong,
                    t.ten_truong,
                    t.ma_cap_hoc,
                    c.ten_cap_hoc,
                    t.ma_loai_truong,
                    l.ten_loai_truong,
                    t.ma_quan_huyen,
                    q.ten_quan_huyen,
                    t.dia_chi,
                    ST_X(t.toa_do) as longitude,
                    ST_Y(t.toa_do) as latitude,
                    t.so_lop,
                    t.so_hoc_sinh,
                    t.dien_thoai,
                    t.email,
                    t.website,
                    t.nam_thanh_lap,
                    t.dien_tich_khuon_vien,
                    t.trang_thai
                FROM truong_hoc t
                JOIN cap_hoc c ON t.ma_cap_hoc = c.ma_cap_hoc
                JOIN loai_truong l ON t.ma_loai_truong = l.ma_loai_truong
                JOIN quan_huyen q ON t.ma_quan_huyen = q.ma_quan_huyen
                WHERE t.so_hoc_sinh > ? AND t.trang_thai = 'Hoạt động'
                ORDER BY t.so_hoc_sinh DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$minStudents]);
        $schools = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $schools,
            'total' => count($schools),
            'min_students' => $minStudents
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi truy vấn database: ' . $e->getMessage()]);
    }
}

function getStatistics() {
    global $pdo;
    
    try {
        // Thống kê theo cấp học
        $sql1 = "SELECT 
                    c.ten_cap_hoc,
                    COUNT(*) as so_truong,
                    SUM(t.so_hoc_sinh) as tong_hoc_sinh,
                    SUM(t.so_lop) as tong_so_lop
                FROM truong_hoc t
                JOIN cap_hoc c ON t.ma_cap_hoc = c.ma_cap_hoc
                WHERE t.trang_thai = 'Hoạt động'
                GROUP BY c.ma_cap_hoc, c.ten_cap_hoc
                ORDER BY so_truong DESC";
        
        $stmt1 = $pdo->prepare($sql1);
        $stmt1->execute();
        $byLevel = $stmt1->fetchAll();
        
        // Thống kê theo quận/huyện
        $sql2 = "SELECT 
                    q.ten_quan_huyen,
                    COUNT(*) as so_truong,
                    SUM(t.so_hoc_sinh) as tong_hoc_sinh
                FROM truong_hoc t
                JOIN quan_huyen q ON t.ma_quan_huyen = q.ma_quan_huyen
                WHERE t.trang_thai = 'Hoạt động'
                GROUP BY q.ma_quan_huyen, q.ten_quan_huyen
                ORDER BY so_truong DESC";
        
        $stmt2 = $pdo->prepare($sql2);
        $stmt2->execute();
        $byDistrict = $stmt2->fetchAll();
        
        // Thống kê theo loại trường
        $sql3 = "SELECT 
                    l.ten_loai_truong,
                    COUNT(*) as so_truong,
                    SUM(t.so_hoc_sinh) as tong_hoc_sinh
                FROM truong_hoc t
                JOIN loai_truong l ON t.ma_loai_truong = l.ma_loai_truong
                WHERE t.trang_thai = 'Hoạt động'
                GROUP BY l.ma_loai_truong, l.ten_loai_truong
                ORDER BY so_truong DESC";
        
        $stmt3 = $pdo->prepare($sql3);
        $stmt3->execute();
        $byType = $stmt3->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => [
                'by_level' => $byLevel,
                'by_district' => $byDistrict,
                'by_type' => $byType
            ]
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi truy vấn database: ' . $e->getMessage()]);
    }
}

function addSchool() {
    global $pdo;
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Chỉ chấp nhận phương thức POST']);
        return;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate dữ liệu đầu vào
    $required = ['ten_truong', 'ma_cap_hoc', 'ma_loai_truong', 'ma_quan_huyen', 'dia_chi', 'longitude', 'latitude'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Thiếu trường bắt buộc: $field"]);
            return;
        }
    }
    
    // Validate tọa độ (Cần Thơ: 105.3-106.0, 9.8-10.4)
    $lng = floatval($input['longitude']);
    $lat = floatval($input['latitude']);
    
    if ($lng < 105.3 || $lng > 106.0 || $lat < 9.8 || $lat > 10.4) {
        http_response_code(400);
        echo json_encode(['error' => 'Tọa độ không thuộc địa phận Cần Thơ']);
        return;
    }
    
    try {
        // Tạo mã trường tự động
        $sql = "SELECT MAX(CAST(SUBSTRING(ma_truong, 3) AS UNSIGNED)) as max_num 
                FROM truong_hoc 
                WHERE ma_truong LIKE ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$input['ma_cap_hoc'] . '%']);
        $result = $stmt->fetch();
        $nextNum = ($result['max_num'] ?? 0) + 1;
        $maTruong = $input['ma_cap_hoc'] . str_pad($nextNum, 3, '0', STR_PAD_LEFT);
        
        $sql = "INSERT INTO truong_hoc (
                    ma_truong, ten_truong, ma_cap_hoc, ma_loai_truong, 
                    ma_quan_huyen, dia_chi, toa_do, so_lop, so_hoc_sinh, 
                    dien_thoai, email, website, nam_thanh_lap, 
                    dien_tich_khuon_vien, trang_thai
                ) VALUES (?, ?, ?, ?, ?, ?, POINT(?, ?), ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $maTruong,
            $input['ten_truong'],
            $input['ma_cap_hoc'],
            $input['ma_loai_truong'],
            $input['ma_quan_huyen'],
            $input['dia_chi'],
            $lng,
            $lat,
            $input['so_lop'] ?? 0,
            $input['so_hoc_sinh'] ?? 0,
            $input['dien_thoai'] ?? '',
            $input['email'] ?? '',
            $input['website'] ?? '',
            $input['nam_thanh_lap'] ?? date('Y'),
            $input['dien_tich_khuon_vien'] ?? 0,
            'Hoạt động'
        ]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Thêm trường học thành công',
            'ma_truong' => $maTruong
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi thêm trường học: ' . $e->getMessage()]);
    }
}

function validateCoordinates() {
    $lng = floatval($_GET['longitude'] ?? 0);
    $lat = floatval($_GET['latitude'] ?? 0);
    
    // Kiểm tra tọa độ có thuộc Cần Thơ không
    $isValid = ($lng >= 105.3 && $lng <= 106.0 && $lat >= 9.8 && $lat <= 10.4);
    
    echo json_encode([
        'success' => true,
        'is_valid' => $isValid,
        'message' => $isValid ? 'Tọa độ hợp lệ' : 'Tọa độ không thuộc địa phận Cần Thơ'
    ]);
}

function updateSchool() {
    global $pdo;
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Chỉ chấp nhận phương thức POST']);
        return;
    }
    
    // Get data from POST (FormData)
    $input = $_POST;
    
    // Validate dữ liệu đầu vào
    $required = ['id', 'ten_truong', 'ma_cap_hoc', 'ma_loai_truong', 'ma_quan_huyen', 'dia_chi', 'longitude', 'latitude'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Thiếu trường bắt buộc: $field"]);
            return;
        }
    }
    
    // Validate tọa độ (Cần Thơ: 105.3-106.0, 9.8-10.4)
    $lng = floatval($input['longitude']);
    $lat = floatval($input['latitude']);
    
    if ($lng < 105.3 || $lng > 106.0 || $lat < 9.8 || $lat > 10.4) {
        http_response_code(400);
        echo json_encode(['error' => 'Tọa độ không thuộc địa phận Cần Thơ']);
        return;
    }
    
    try {
        $sql = "UPDATE truong_hoc SET 
                    ten_truong = ?, 
                    ma_cap_hoc = ?, 
                    ma_loai_truong = ?, 
                    ma_quan_huyen = ?, 
                    dia_chi = ?, 
                    toa_do = POINT(?, ?), 
                    so_lop = ?, 
                    so_hoc_sinh = ?, 
                    dien_thoai = ?, 
                    email = ?, 
                    website = ?
                WHERE ma_truong = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $input['ten_truong'],
            $input['ma_cap_hoc'],
            $input['ma_loai_truong'],
            $input['ma_quan_huyen'],
            $input['dia_chi'],
            $lng,
            $lat,
            $input['so_lop'] ?? 0,
            $input['so_hoc_sinh'] ?? 0,
            $input['dien_thoai'] ?? '',
            $input['email'] ?? '',
            $input['website'] ?? '',
            $input['id']
        ]);
        
        // Get updated school data
        $sql = "SELECT 
                    t.ma_truong as id,
                    t.ten_truong,
                    t.ma_cap_hoc,
                    c.ten_cap_hoc,
                    t.ma_loai_truong,
                    l.ten_loai_truong,
                    t.ma_quan_huyen,
                    q.ten_quan_huyen,
                    t.dia_chi,
                    ST_X(t.toa_do) as longitude,
                    ST_Y(t.toa_do) as latitude,
                    t.so_lop,
                    t.so_hoc_sinh,
                    t.dien_thoai,
                    t.email,
                    t.website
                FROM truong_hoc t
                JOIN cap_hoc c ON t.ma_cap_hoc = c.ma_cap_hoc
                JOIN loai_truong l ON t.ma_loai_truong = l.ma_loai_truong
                JOIN quan_huyen q ON t.ma_quan_huyen = q.ma_quan_huyen
                WHERE t.ma_truong = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$input['id']]);
        $school = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật trường học thành công',
            'data' => $school
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi cập nhật trường học: ' . $e->getMessage()]);
    }
}

function deleteSchool() {
    global $pdo;
    
    if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
        http_response_code(405);
        echo json_encode(['error' => 'Chỉ chấp nhận phương thức DELETE']);
        return;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['id']) || empty($input['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Thiếu mã trường học']);
        return;
    }
    
    try {
        $sql = "DELETE FROM truong_hoc WHERE ma_truong = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$input['id']]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Xóa trường học thành công'
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Không tìm thấy trường học để xóa']);
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi xóa trường học: ' . $e->getMessage()]);
    }
}

function updateSchoolPosition() {
    global $pdo;
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Chỉ chấp nhận phương thức POST']);
        return;
    }
    
    // Get data from POST
    $input = $_POST;
    
    // Validate required fields
    $required = ['id', 'latitude', 'longitude'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Thiếu trường bắt buộc: $field"]);
            return;
        }
    }
    
    try {
        // Validate coordinates
        $latitude = floatval($input['latitude']);
        $longitude = floatval($input['longitude']);
        
        if ($latitude < -90 || $latitude > 90) {
            http_response_code(400);
            echo json_encode(['error' => 'Vĩ độ phải trong khoảng -90 đến 90']);
            return;
        }
        
        if ($longitude < -180 || $longitude > 180) {
            http_response_code(400);
            echo json_encode(['error' => 'Kinh độ phải trong khoảng -180 đến 180']);
            return;
        }
        
        // Update school position
        $sql = "UPDATE truong_hoc SET toa_do = POINT(?, ?) WHERE ma_truong = ?";
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([$longitude, $latitude, $input['id']]);
        
        if ($result && $stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => 'Cập nhật vị trí trường học thành công']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Không tìm thấy trường học để cập nhật']);
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi cập nhật vị trí: ' . $e->getMessage()]);
    }
}

function getDistrictStats() {
    global $pdo;
    
    try {
        $sql = "SELECT 
                    qh.ten_quan_huyen,
                    COUNT(t.ma_truong) as so_truong,
                    COALESCE(SUM(t.so_hoc_sinh), 0) as so_hoc_sinh
                FROM quan_huyen qh
                LEFT JOIN truong_hoc t ON qh.ma_quan_huyen = t.ma_quan_huyen
                GROUP BY qh.ma_quan_huyen, qh.ten_quan_huyen
                ORDER BY so_truong DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Lỗi lấy thống kê quận/huyện: ' . $e->getMessage()]);
    }
}
?>
