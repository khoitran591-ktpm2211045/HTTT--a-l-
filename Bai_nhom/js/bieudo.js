// Chart variables
let chart = null;
let chartType = 'schools'; // 'schools' or 'students'

// Chart functions
function showChart(type) {
    chartType = type;
    
    // Update button states
    document.querySelectorAll('.chart-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // Load and display chart
    loadChartData();
}

function loadChartData() {
    fetch('api/schools.php?action=get_district_stats')
        .then(response => response.json())
        .then(data => {
        if (data.success) {
                updateChart(data.data);
        } else {
                console.error('Error loading chart data:', data.error);
            }
        })
        .catch(error => {
            console.error('Error loading chart data:', error);
        });
}

function updateChart(data) {
     const ctx = document.getElementById('districtChart');
    if (!ctx) {
        console.error('Canvas element not found!');
        return;
    }
    
    // Destroy existing chart
    if (chart) {
        chart.destroy();
    }
    
    // Prepare data based on chart type
    let labels, values, backgroundColor;
    
    if (chartType === 'schools') {
        labels = data.map(item => item.ten_quan_huyen);
        values = data.map(item => parseInt(item.so_truong));
        backgroundColor = generateColors(data.length);
    } else {
        labels = data.map(item => item.ten_quan_huyen);
        values = data.map(item => parseInt(item.so_hoc_sinh));
        backgroundColor = generateColors(data.length);
    }
    
    // Create pie chart
    chart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: values,
                backgroundColor: backgroundColor,
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 20,
                        usePointStyle: true
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${label}: ${value} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

function generateColors(count) {
    const colors = [
        '#e74c3c', '#f39c12', '#27ae60', '#3498db', '#9b59b6', '#e67e22',
        '#1abc9c', '#34495e', '#e91e63', '#ff9800', '#4caf50', '#2196f3',
        '#9c27b0', '#ff5722', '#00bcd4', '#795548', '#607d8b', '#ffc107'
    ];
    
    const result = [];
    for (let i = 0; i < count; i++) {
        result.push(colors[i % colors.length]);
    }
    return result;
}

// Initialize chart on page load
document.addEventListener('DOMContentLoaded', function() {
    // Load chart data after a short delay to ensure DOM is ready
    setTimeout(() => {
        loadChartData();
    }, 1000);
});

// Export functions to global scope
window.showChart = showChart;