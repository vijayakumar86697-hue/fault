# run_springboot.ps1
$classpath = "target\classes;src\main\webapp;" + (Get-Content "d:\New folder\classpath.txt")
Write-Host "Launching Campus Infrastructure Fault Reporting System (Spring Boot 3.2)..."
java -cp $classpath com.campus.CampusFaultSystemApplication
