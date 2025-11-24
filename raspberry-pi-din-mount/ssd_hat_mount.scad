translate([0, -8, -33]) // offset with plate origin on y & flush with plane on z
import("../models/DIN_Rail_Cable_Clamp.stl");

module pi5() {
    include <pi5.scad>
}
translate([0, 0, -113])
rotate([0,180,0])
    %pi5();

translate([0, 2, -3])
cube([60, 2, 6], center=true);

// Raspberry Pi 5 Mounting Plate

// === Parameters ===
// Pi 5 board dimensions (from official spec)
//pi_width  = 85;
//pi_height = 56;
hole_offset_x   = 58;
hole_offset_y   = 49;
pi_overhang = 20;

margin = 5; // margin beyond the holes
plate_thick = 2.5;
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

ssd_w = 100;
ssd_h = 70;
ssd_z = 6;
module ssd() {
    %cube([ssd_w, ssd_h, ssd_z], center=true);
}

module fan_holes(thick) {
    diameter = 32;
    offset = diameter/2;
    translate([0, 0, thick/2-0.01]) {
        cylinder(h = thick+0.1, d = 32, $fn = 48, center=true);
        translate([-offset, -offset, 0])
            cylinder(h = thick+0.1, d = 3.2, $fn = 48, center=true);
        translate([-offset, offset, 0])
            cylinder(h = thick+0.1, d = 3.2, $fn = 48, center=true);
        translate([offset, offset, 0])
            cylinder(h = thick+0.1, d = 3.2, $fn = 48, center=true);
        translate([offset, -offset, 0])
            cylinder(h = thick+0.1, d = 3.2, $fn = 48, center=true);
    }
}

mirror([0, 0, 1])
mirror([1, 0, 0]) // it's a "top mounted" plate
difference() {
    // Full plate size
    plate_w = hole_offset_x  + 2 * margin + pi_overhang;
    plate_h = hole_offset_y + 2 * margin;

    hole_inset = (plate_h - hole_offset_y) / 2;
    hole_x_left = - plate_w/2 + hole_inset;
    hole_x_right = hole_x_left+hole_offset_x;
    hole_y_bottom = hole_inset;
    hole_y_top = hole_y_bottom+hole_offset_y;

    standoff_height = 7;
    hole_diameter = 2.9;

    ssd_offset_x = 9; // offset to bottom right hole
    ssd_offset_y = 8; // offset to bottom right hole
    // ssd positioning
    ssd_translate = [hole_x_right - ssd_h/2 + ssd_offset_x, hole_y_bottom + ssd_offset_y, ssd_w/2 + plate_thick + 5];
    ssd_offset = [0, 11.5, 0]; // offset of each ssd
    ssd_rotate = [90, 90, 0];

    ssd_wall_h = ssd_translate.y + 3*ssd_offset.y + 5;
    ssd_wall_thick = plate_thick;
    ssd_hole_clearing = 11; // distance of the holes from the plate
    ssd_wall_tall = ssd_hole_clearing + hole_diameter/2 + 2; // how tall to stand off of plate
    ssd_wall_padding = 1.6; // how much padding from wall to ssd
    ssd_wall_gap = [ssd_h + 2*ssd_wall_padding + ssd_wall_thick, 0, 0];

    ssd_wall_translate = [hole_x_right+ssd_offset_x+ssd_wall_padding, 0, ssd_wall_tall/2+ssd_wall_thick/2];
    ssd_wall_rotate = [0, 90, 0];

    union() {
        // pi "main" plate
//        %rounded_plate(plate_w, plate_h, plate_thick, 0, corner_radius);
        translate([ssd_translate.x, ssd_wall_h/2, 0])
        cube([ssd_h + 2*ssd_wall_padding+2*ssd_wall_thick, ssd_wall_h, plate_thick], center=true);

        standoff_diameter = hole_diameter + 2*1.6; // hole + 2*min

        // ssds
        translate(ssd_translate)
        rotate(ssd_rotate)
            ssd();
        translate(ssd_translate + ssd_offset)
            rotate(ssd_rotate)
            ssd();
        translate(ssd_translate + 2*ssd_offset)
            rotate(ssd_rotate)
                ssd();
        translate(ssd_translate + 3*ssd_offset)
            rotate(ssd_rotate)
                ssd();

        // ssd hole wall
        translate(ssd_wall_translate)
        rotate(ssd_wall_rotate)
            rounded_plate(ssd_wall_tall+ssd_wall_thick, ssd_wall_h, ssd_wall_thick, [0, 0, 0], 1);
        translate(ssd_wall_translate - ssd_wall_gap)
            rotate(ssd_wall_rotate)
                rounded_plate(ssd_wall_tall+ssd_wall_thick, ssd_wall_h, ssd_wall_thick, [0, 0, 0], 1);
    }

    // ssd holes
    ssd_hole_translate = [ssd_wall_translate.x+ssd_wall_thick/2, hole_y_bottom+ssd_offset_y, plate_thick+ssd_hole_clearing];
    ssd_hole_rotate = [0, 90, 0];
    translate(ssd_hole_translate)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + ssd_offset)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + 2*ssd_offset)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + 3*ssd_offset)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);

    translate(ssd_hole_translate - ssd_wall_gap)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + ssd_offset - ssd_wall_gap)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + 2*ssd_offset - ssd_wall_gap)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);
    translate(ssd_hole_translate + 3*ssd_offset - ssd_wall_gap)
        rotate(ssd_hole_rotate)
            cylinder(h = ssd_wall_thick + 0.01, d = hole_diameter, $fn = 48, center=true);

    // fan hole
    fan_diameter = 35;
    translate([ssd_translate.x/2, ssd_wall_h/2, -ssd_wall_thick/2])
//        cylinder(h = ssd_wall_thick + 0.01, d = fan_diameter, $fn = 48);
    fan_holes(ssd_wall_thick);
}
