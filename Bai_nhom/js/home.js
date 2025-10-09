// Home page JavaScript
document.addEventListener('DOMContentLoaded', function() {
    loadStatistics();
});

// Load statistics for home page
async function loadStatistics() {
    try {
        const response = await fetch('api/schools.php?action=get_statistics');
        const data = await response.json();
        
        if (data.success) {
            updateStatistics(data.data);
        } else {
            console.error('Lỗi tải thống kê:', data.error);
        }
    } catch (error) {
        console.error('Lỗi kết nối:', error.message);
    }
}

// Update statistics display
function updateStatistics(stats) {
    const totalSchoolsEl = document.getElementById('total-schools');
    const totalStudentsEl = document.getElementById('total-students');
    const totalClassesEl = document.getElementById('total-classes');
    const activeSchoolsEl = document.getElementById('active-schools');
    
    if (totalSchoolsEl) totalSchoolsEl.textContent = stats.tong_truong || 0;
    if (totalStudentsEl) totalStudentsEl.textContent = (stats.tong_hoc_sinh || 0).toLocaleString();
    if (totalClassesEl) totalClassesEl.textContent = stats.tong_lop || 0;
    if (activeSchoolsEl) activeSchoolsEl.textContent = stats.truong_hoat_dong || 0;
}
