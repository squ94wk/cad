// Raspberry Pi 5 Mounting Plate

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
module rounded_plate(w, h, t, a, r) {
    // A rounded rectangle can be made via Minkowski sum
    minkowski() {
        translate([0, h/2, t/2])
            rotate(a)
                cube([w - 2*r, h - 2*r, t], center=true);
        cylinder(r=r, h=0.0001, $fn=64); // 2D corner shape
    }
}

// Full plate size
plate_w = hole_offset_x  + 2 * margin + pi_overhang;
plate_h = hole_offset_y + 2 * margin;

hole_inset = (plate_h - hole_offset_y) / 2;
hole_x_left = - plate_w/2 + hole_inset;
hole_x_right = hole_x_left+hole_offset_x;
hole_y_bottom = hole_inset;
hole_y_top = hole_y_bottom+hole_offset_y;

module pi5() {
    // din rail mount
    translate([0, -8, -27]) // offset with plate origin on y & flush with plane on z
        mirror([1, 0, 0])
            import("../models/DIN_Rail_Cable_Clamp.stl");

    // filler
    translate([0, 2, 3])
        cube([60, 2, 6], center=true);

    // pi mount
    difference() {
        standoff_height = 7;
        hole_diameter = 4;

        union() {
            // pi "main" plate
            rounded_plate(plate_w, plate_h, plate_thick, 0, corner_radius);

            standoff_diameter = hole_diameter + 2*1.6; // hole + 2*min

            // standoff cylinders
            translate([hole_x_left, hole_y_bottom, 0])
                cylinder(h = standoff_height, d = standoff_diameter, $fn = 48);
            translate([hole_x_right, hole_y_bottom, 0])
                cylinder(h = standoff_height, d = standoff_diameter, $fn = 48);
            translate([hole_x_left, hole_y_top, 0])
                cylinder(h = standoff_height, d = standoff_diameter, $fn = 48);
            translate([hole_x_right, hole_y_top, 0])
                cylinder(h = standoff_height, d = standoff_diameter, $fn = 48);
        }

        // holes
        hole_depth = 6;
        hole_z = standoff_height - hole_depth;

        translate([hole_x_left, hole_y_bottom, hole_z])
            cylinder(h = hole_depth + 0.01, d = hole_diameter, $fn = 48);
        translate([hole_x_right, hole_y_bottom, hole_z])
            cylinder(h = hole_depth + 0.01, d = hole_diameter, $fn = 48);
        translate([hole_x_left, hole_y_top, hole_z])
            cylinder(h = hole_depth + 0.01, d = hole_diameter, $fn = 48);
        translate([hole_x_right, hole_y_top, hole_z])
            cylinder(h = hole_depth + 0.01, d = hole_diameter, $fn = 48);
    }
}

pi5();