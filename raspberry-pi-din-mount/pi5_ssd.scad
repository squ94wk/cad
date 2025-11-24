// Raspberry Pi 5 Mounting Plate with SSD mounting holes

// === Parameters ===
// Pi 5 board dimensions (from official spec)
//pi_width  = 85;
//pi_height = 56;
hole_offset_x   = 58;
hole_offset_y   = 49;
pi_overhang = 20;

margin = 5; // margin beyond the holes
plate_thick = 2;
corner_radius = 5;

// === Plate ===
use <pi5.scad>

module ssd_cross() {
    difference() {
        // Full plate size
        plate_w = hole_offset_x  + 2 * margin + pi_overhang;
        plate_h = hole_offset_y + 2 * margin;

        hole_inset = (plate_h - hole_offset_y) / 2;
        hole_x_left = - plate_w/2 + hole_inset;
        hole_x_right = hole_x_left+hole_offset_x;
        hole_y_bottom = hole_inset;
        hole_y_top = hole_y_bottom+hole_offset_y;

        // SSD (2.5") backside mount through-holes
        ssd_hole_diameter = 3.2; // M3 clearance
        ssd_hole_offset_x = 76.6;
        ssd_hole_offset_y = 61.72;

        union() {
            // ssd cross plate
            // Length between opposite SSD holes (diagonal)
            ssd_hole_diagonal = sqrt(ssd_hole_offset_x*ssd_hole_offset_x + ssd_hole_offset_y*ssd_hole_offset_y);
            // Cross rotation angle so the long edges align with the SSD hole diagonals
            ssd_cross_angle = atan2(ssd_hole_offset_y, ssd_hole_offset_x);
            translate([0, hole_y_bottom-margin+hole_offset_y/2, 0]){
                rounded_plate(ssd_hole_diagonal+2*margin, 2*margin+0.1, plate_thick, ssd_cross_angle, corner_radius);
                rounded_plate(ssd_hole_diagonal+2*margin, 2*margin+0.1, plate_thick, -ssd_cross_angle, corner_radius);
            }
        }

        // SSD through-holes (no standoffs), using true SSD pattern spacing
        // Anchor: lower-left SSD hole shares Y with Pi bottom hole and is 6 mm right of Pi left hole
        ssd_hole_x_left = -ssd_hole_offset_x/2;
        ssd_hole_x_right = ssd_hole_x_left + ssd_hole_offset_x;
        ssd_hole_y_bottom = hole_y_bottom + (hole_offset_y - ssd_hole_offset_y)/2;
        ssd_hole_y_top = ssd_hole_y_bottom + ssd_hole_offset_y;

        translate([ssd_hole_x_left, ssd_hole_y_bottom, 0])
            cylinder(h = plate_thick + 0.02, d = ssd_hole_diameter, $fn = 48);
        translate([ssd_hole_x_right, ssd_hole_y_bottom, 0])
            cylinder(h = plate_thick + 0.02, d = ssd_hole_diameter, $fn = 48);
        translate([ssd_hole_x_left, ssd_hole_y_top, 0])
            cylinder(h = plate_thick + 0.02, d = ssd_hole_diameter, $fn = 48);
        translate([ssd_hole_x_right, ssd_hole_y_top, 0])
            cylinder(h = plate_thick + 0.02, d = ssd_hole_diameter, $fn = 48);
    }
}

mirror([0, 0, 1]) {
    pi5();
    ssd_cross();
}

