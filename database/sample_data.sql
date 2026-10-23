-- ============================================================================
-- Campus Infrastructure Fault Reporting System
-- Sample Data Script: sample_data.sql
-- ============================================================================

USE `campus_fault_db`;

-- ----------------------------------------------------------------------------
-- 1. Insert Campus Buildings
-- ----------------------------------------------------------------------------
INSERT INTO `buildings` (`id`, `name`, `code`, `floors`, `description`, `is_active`) VALUES
(1, 'Engineering & Computing Complex', 'ENG-B', 5, 'Contains Computer Science, Electrical, and Electronics labs and lecture halls.', 1),
(2, 'Science & Technology Block', 'SCI-A', 4, 'Houses Physics, Chemistry, and Biotechnology research laboratories.', 1),
(3, 'Central Library & Media Center', 'LIB-01', 3, 'Main digital library, reading rooms, quiet zones, and archives.', 1),
(4, 'Administrative & Faculty Tower', 'ADM-01', 6, 'Dean office, registrar, accounts, HR, and faculty cabins.', 1),
(5, 'Student Hostel Block 1 (Boys)', 'HST-B1', 4, 'Residential block 1 for male undergraduate students.', 1),
(6, 'Student Hostel Block 2 (Girls)', 'HST-G1', 4, 'Residential block 2 for female undergraduate students.', 1),
(7, 'Campus Sports & Recreation Complex', 'SPT-01', 2, 'Indoor badminton courts, gym, cafeteria, and student council lounge.', 1)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- ----------------------------------------------------------------------------
-- 2. Insert Fault Categories
-- ----------------------------------------------------------------------------
INSERT INTO `fault_categories` (`id`, `name`, `icon`, `description`, `default_priority`, `is_active`) VALUES
(1, 'Electrical faults', 'bi-lightning-charge', 'Fans, lights, power sockets, switchboards, wiring, circuit breakers.', 'MEDIUM', 1),
(2, 'Plumbing faults', 'bi-droplet-half', 'Leaking taps, burst pipes, blocked drains, toilets, overhead water tanks.', 'HIGH', 1),
(3, 'Furniture faults', 'bi-lamp', 'Broken desks, chairs, lecture benches, podiums, broken door locks.', 'LOW', 1),
(4, 'Building faults', 'bi-building-exclamation', 'Cracked plaster, leaking ceilings, broken glass windows, damaged tiles.', 'HIGH', 1),
(5, 'Laboratory faults', 'bi-radioactive', 'Defective laboratory instruments, fume hoods, gas line regulators.', 'HIGH', 1),
(6, 'Network and IT faults', 'bi-wifi', 'Campus Wi-Fi APs, overhead projectors, smart boards, network switch ports.', 'MEDIUM', 1),
(7, 'Cleaning and sanitation', 'bi-trash', 'Overflowing waste receptacles, uncleaned restrooms, chemical spills.', 'MEDIUM', 1),
(8, 'Safety hazards', 'bi-shield-exclamation', 'Exposed high-voltage cables, slippery stairways, damaged fire extinguishers.', 'CRITICAL', 1),
(9, 'Other infrastructure issues', 'bi-question-circle', 'General campus infrastructure, parking shade damage, signboards.', 'LOW', 1)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- ----------------------------------------------------------------------------
-- 3. Insert Users (Admin, Students, Faculty, Maintenance Staff)
-- Passwords:
-- admin / admin123
-- student1 / student123
-- sarah_m / student123
-- prof_smith / faculty123
-- dr_anita / faculty123
-- worker_elec / worker123
-- worker_plumb / worker123
-- worker_it / worker123
-- worker_civil / worker123
-- ----------------------------------------------------------------------------
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `phone`, `role`, `department`, `worker_specialty`, `status`) VALUES
(1, 'admin', '$2a$12$QBbFzo5dNpvT/yoDnhv0ZOCi0tYw9sz3NRaNu26ha9QAI4qcAtdj6', 'Dr. Robert Vance', 'admin@campus.edu', '+1 (555) 019-2831', 'ADMIN', 'Campus Estate & Facilities Management', NULL, 'ACTIVE'),
(2, 'student1', '$2a$12$ru47z0ArdJEiIaRHfaEVve9AFcG9H9rT/d/u6f0CyXoxxaUfRTUXi', 'John Doe', 'john.doe@student.campus.edu', '+1 (555) 014-9921', 'STUDENT', 'Computer Science & Engineering', NULL, 'ACTIVE'),
(3, 'sarah_m', '$2a$12$ru47z0ArdJEiIaRHfaEVve9AFcG9H9rT/d/u6f0CyXoxxaUfRTUXi', 'Sarah Miller', 'sarah.m@student.campus.edu', '+1 (555) 018-4720', 'STUDENT', 'Electronics & Communication', NULL, 'ACTIVE'),
(4, 'prof_smith', '$2a$12$nrZ07x4mwggbDTWL0.jP9OrFm3HDmeDhWCPUQOFlUgxpOgQC3Bb6W', 'Prof. Arthur Smith', 'arthur.smith@campus.edu', '+1 (555) 016-3391', 'FACULTY', 'Mechanical Engineering Department', NULL, 'ACTIVE'),
(5, 'dr_anita', '$2a$12$nrZ07x4mwggbDTWL0.jP9OrFm3HDmeDhWCPUQOFlUgxpOgQC3Bb6W', 'Dr. Anita Desai', 'anita.desai@campus.edu', '+1 (555) 017-8820', 'FACULTY', 'Physics Department', NULL, 'ACTIVE'),
(6, 'worker_elec', '$2a$12$f0OZ8/eZeHxy4g2ZmGNkKuRGc9DznYVBJ6ltBhHOpbOO611GrjJTa', 'David Miller', 'david.elec@maintenance.campus.edu', '+1 (555) 012-7711', 'WORKER', 'Maintenance Services', 'Electrical faults', 'ACTIVE'),
(7, 'worker_plumb', '$2a$12$f0OZ8/eZeHxy4g2ZmGNkKuRGc9DznYVBJ6ltBhHOpbOO611GrjJTa', 'James Wilson', 'james.plumb@maintenance.campus.edu', '+1 (555) 013-4482', 'WORKER', 'Maintenance Services', 'Plumbing faults', 'ACTIVE'),
(8, 'worker_it', '$2a$12$f0OZ8/eZeHxy4g2ZmGNkKuRGc9DznYVBJ6ltBhHOpbOO611GrjJTa', 'Alex Chen', 'alex.chen@maintenance.campus.edu', '+1 (555) 015-8833', 'WORKER', 'Campus IT Network Team', 'Network and IT faults', 'ACTIVE'),
(9, 'worker_civil', '$2a$12$f0OZ8/eZeHxy4g2ZmGNkKuRGc9DznYVBJ6ltBhHOpbOO611GrjJTa', 'Carlos Santana', 'carlos.civil@maintenance.campus.edu', '+1 (555) 019-5501', 'WORKER', 'Civil Infrastructure Team', 'Building faults', 'ACTIVE')
ON DUPLICATE KEY UPDATE `password_hash`=VALUES(`password_hash`);

-- ----------------------------------------------------------------------------
-- 4. Insert Complaints
-- ----------------------------------------------------------------------------
INSERT INTO `complaints` (`id`, `ticket_number`, `reporter_id`, `category_id`, `building_id`, `block_floor`, `room_location`, `title`, `description`, `priority`, `status`, `reopen_count`, `submitted_at`, `resolved_at`, `closed_at`) VALUES
(1, 'CMP-2026-0001', 2, 8, 1, 'Block C, Ground Floor', 'Room EE-102 (Electrical Machine Lab)', 'Main Switchboard Sparking Under High Load', 'The main 3-phase switchboard near the bench starts sparking and emits an electrical burning smell when motors are tested. Urgent safety hazard.', 'CRITICAL', 'IN_PROGRESS', 0, DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, NULL),

(2, 'CMP-2026-0002', 4, 2, 2, 'North Wing, 2nd Floor', 'Faculty Restroom 204', 'Continuous Water Leakage from Main Flush Pipe', 'The main inlet valve in the second floor faculty restroom is cracked and leaking water continuously across the tiled floor, causing slipping hazard.', 'HIGH', 'ASSIGNED', 0, DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL),

(3, 'CMP-2026-0003', 3, 6, 1, 'Block A, 3rd Floor', 'Lecture Hall 301', 'Ceiling Projector HDMI Port Damaged and Flickering', 'The overhead ceiling projector HDMI connection port has broken pins. Display flickers pink and disconnects every few minutes during lectures.', 'MEDIUM', 'COMPLETED', 0, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL),

(4, 'CMP-2026-0004', 5, 1, 3, 'East Wing, 1st Floor', 'Quiet Study Zone B', 'Ceiling Fan Making High Pitched Grinding Sound', 'The ceiling fan above study table 4 makes an unbearable metallic scraping noise and wobbles during operation.', 'LOW', 'CLOSED', 0, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),

(5, 'CMP-2026-0005', 2, 3, 5, 'Block 1, 2nd Floor', 'Common Study Lounge', 'Multiple Broken Study Desk Chairs with Exposed Metal Bolts', 'Four rolling chairs in the hostel study lounge have broken backrests and exposed metal edges that can cut clothes or cause injury.', 'LOW', 'SUBMITTED', 0, DATE_SUB(NOW(), INTERVAL 3 HOUR), NULL, NULL),

(6, 'CMP-2026-0006', 4, 6, 4, '4th Floor Server Room', 'Data Center Room 402', 'Precision AC Unit 2 Condensate Pipe Leaking near Server Rack 3', 'Condensate drain line for Precision AC #2 has detached at the elbow joint. Water is dripping onto the anti-static raised flooring 2 feet away from primary network switches.', 'CRITICAL', 'UNDER_REVIEW', 0, DATE_SUB(NOW(), INTERVAL 6 HOUR), NULL, NULL)
ON DUPLICATE KEY UPDATE `ticket_number`=VALUES(`ticket_number`);

-- ----------------------------------------------------------------------------
-- 5. Insert Complaint Assignments
-- ----------------------------------------------------------------------------
INSERT INTO `complaint_assignments` (`id`, `complaint_id`, `worker_id`, `assigned_by`, `assigned_at`, `instructions`, `expected_completion`, `is_active`) VALUES
(1, 1, 6, 1, DATE_SUB(NOW(), INTERVAL 36 HOUR), 'Inspect the 3-phase busbar connections and replace the faulty 63A MCB breaker immediately. Follow all lockout/tagout safety procedures.', CURDATE() + INTERVAL 1 DAY, 1),
(2, 2, 7, 1, DATE_SUB(NOW(), INTERVAL 18 HOUR), 'Shut off the isolation valve on the riser, replace the broken PVC coupler and test pressure.', CURDATE() + INTERVAL 2 DAY, 1),
(3, 3, 8, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Replace the ceiling HDMI wall plate and test with both Mac and Windows test laptops.', CURDATE() - INTERVAL 1 DAY, 1),
(4, 4, 6, 1, DATE_SUB(NOW(), INTERVAL 6 DAY), 'Lubricate or replace the motor bearing of the fan. Rebalance fan blades.', CURDATE() - INTERVAL 5 DAY, 0)
ON DUPLICATE KEY UPDATE `complaint_id`=VALUES(`complaint_id`);

-- ----------------------------------------------------------------------------
-- 6. Insert Status History
-- ----------------------------------------------------------------------------
INSERT INTO `complaint_status_history` (`complaint_id`, `changed_by`, `previous_status`, `new_status`, `remarks`, `created_at`) VALUES
(1, 2, NULL, 'SUBMITTED', 'Complaint submitted by John Doe via student portal.', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 1, 'SUBMITTED', 'UNDER_REVIEW', 'Reviewed and verified priority as Critical by Administrator.', DATE_SUB(NOW(), INTERVAL 40 HOUR)),
(1, 1, 'UNDER_REVIEW', 'ASSIGNED', 'Assigned to David Miller (Electrical Specialist).', DATE_SUB(NOW(), INTERVAL 36 HOUR)),
(1, 6, 'ASSIGNED', 'IN_PROGRESS', 'Worker arrived at EE-102 workshop. Isolated breaker panel.', DATE_SUB(NOW(), INTERVAL 24 HOUR)),

(2, 4, NULL, 'SUBMITTED', 'Complaint submitted by Prof. Arthur Smith.', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 1, 'SUBMITTED', 'ASSIGNED', 'Assigned to James Wilson (Plumbing specialist).', DATE_SUB(NOW(), INTERVAL 18 HOUR)),

(3, 3, NULL, 'SUBMITTED', 'Reported projector defect by Sarah Miller.', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3, 1, 'SUBMITTED', 'ASSIGNED', 'Assigned to Alex Chen (Network/IT Specialist).', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 8, 'ASSIGNED', 'IN_PROGRESS', 'Replaced the wall plate, testing signal throughput.', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 8, 'IN_PROGRESS', 'COMPLETED', 'HDMI cable and port replaced. 4K 60Hz projection confirmed working.', DATE_SUB(NOW(), INTERVAL 1 DAY)),

(4, 5, NULL, 'SUBMITTED', 'Reported noisy fan by Dr. Anita Desai.', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(4, 1, 'SUBMITTED', 'ASSIGNED', 'Assigned to David Miller.', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(4, 6, 'ASSIGNED', 'COMPLETED', 'Bearings replaced and blades balanced. Operating silently.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 1, 'COMPLETED', 'CLOSED', 'Resolution verified by Estate Admin. Ticket closed.', DATE_SUB(NOW(), INTERVAL 4 DAY)),

(5, 2, NULL, 'SUBMITTED', 'Submitted by student John Doe.', DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(6, 4, NULL, 'SUBMITTED', 'Emergency report submitted by Prof. Arthur Smith.', DATE_SUB(NOW(), INTERVAL 6 HOUR)),
(6, 1, 'SUBMITTED', 'UNDER_REVIEW', 'Admin marked as Critical emergency. Alerted civil and AC team.', DATE_SUB(NOW(), INTERVAL 5 HOUR));

-- ----------------------------------------------------------------------------
-- 7. Insert Comments
-- ----------------------------------------------------------------------------
INSERT INTO `complaint_comments` (`complaint_id`, `user_id`, `comment_text`, `is_internal`, `created_at`) VALUES
(1, 1, 'David, please make sure the main power feeder is shut off at the substation before opening the panel.', 0, DATE_SUB(NOW(), INTERVAL 35 HOUR)),
(1, 6, 'Power has been locked out. Discovered loose neutral terminal that caused arcing. Installing new industrial breaker now.', 0, DATE_SUB(NOW(), INTERVAL 20 HOUR)),
(3, 8, 'Installed an amplified high-speed HDMI wall jack. Verified projection with both Windows and Mac laptops.', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 3, 'Thank you! The presentation today worked smoothly without any flicker.', 0, DATE_SUB(NOW(), INTERVAL 20 HOUR));

-- ----------------------------------------------------------------------------
-- 8. Insert In-App Notifications
-- ----------------------------------------------------------------------------
INSERT INTO `notifications` (`user_id`, `complaint_id`, `title`, `message`, `type`, `is_read`, `created_at`) VALUES
(2, 1, 'Complaint In Progress', 'Your complaint CMP-2026-0001 status changed to IN PROGRESS by David Miller.', 'INFO', 0, DATE_SUB(NOW(), INTERVAL 24 HOUR)),
(6, 1, 'New Work Assigned', 'You have been assigned complaint CMP-2026-0001 (Priority: CRITICAL).', 'WARNING', 1, DATE_SUB(NOW(), INTERVAL 36 HOUR)),
(4, 2, 'Work Assigned', 'Your complaint CMP-2026-0002 has been assigned to James Wilson.', 'INFO', 0, DATE_SUB(NOW(), INTERVAL 18 HOUR)),
(3, 3, 'Complaint Completed', 'Your complaint CMP-2026-0003 has been marked COMPLETED. Please review.', 'SUCCESS', 1, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 6, 'New Critical Complaint', 'CMP-2026-0006 reported in Server Room 402 requiring immediate review.', 'DANGER', 0, DATE_SUB(NOW(), INTERVAL 6 HOUR));
