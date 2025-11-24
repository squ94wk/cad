translate([0, -8, -33]) // offset with plate origin on y & flush with plane on z
mirror([1, 0, 0])
    import("../models/DIN_Rail_Cable_Clamp.stl");

translate([0, 2, -3])
cube([60, 2, 6], center=true);

// Raspberry Pi Compute Module (4 & 5) Mounting Plate

// === Parameters ===
// Pi CM 4 board dimensions (from official spec)
hole_offset_x   = 33;
hole_offset_y   = 48;
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

mirror([0, 0, 1])
difference() {
    // Full plate size
    plate_w = hole_offset_x  + 2 * margin + pi_overhang;
    plate_h = hole_offset_y + 2 * margin;

    hole_inset = (plate_h - hole_offset_y) / 2;
    hole_x_left = - plate_w/2 + hole_inset;
    hole_x_right = hole_x_left+hole_offset_x;
    hole_y_bottom = hole_inset;
    hole_y_top = hole_y_bottom+hole_offset_y;

    standoff_height = 6;
    hole_diameter = 2.9;

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

        // cable clip
        difference() {
            cable_clip_w = 20;
            cable_clip_h = 3.5;
            overlap = 10; // ensure the corners are covered
            translate([plate_w/2-cable_clip_w/2, plate_h + cable_clip_h/2 - overlap, 0])
                rounded_plate(cable_clip_w, cable_clip_h+overlap, plate_thick, 0, 2);

            slit_w = 10;
            slit_h = 3;
            translate([plate_w/2-cable_clip_w/2, plate_h, -0.5])
                rounded_plate(slit_w, slit_h, plate_thick+1, 0, 1.25);
        }
    }

    // holes
    hole_depth = 7;
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
