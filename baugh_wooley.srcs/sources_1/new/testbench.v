`timescale 1ns / 1ps

//
// Testbench for 4x4 Baugh-Wooley Multiplier
// Tests two's complement signed multiplication
//

module baugh_wooley_4x4_tb;

    // Testbench signals
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;
    
    // Expected result for verification
    reg signed [7:0] expected;
    integer errors;
    integer test_count;

    // Instantiate the Baugh-Wooley multiplier
    baugh_wooley_4x4 uut (
        .a(a),
        .b(b),
        .p(p)
    );

    // Function to convert 4-bit to signed integer for display
    function integer to_signed_4bit;
        input [3:0] val;
        begin
            to_signed_4bit = (val[3]) ? (val | 32'hFFFFFFF0) : val;
        end
    endfunction

    // Function to convert 8-bit to signed integer for display
    function integer to_signed_8bit;
        input [7:0] val;
        begin
            to_signed_8bit = (val[7]) ? (val | 32'hFFFFFF00) : val;
        end
    endfunction

    // Task to check result
    task check_result;
        input [3:0] test_a;
        input [3:0] test_b;
        input [7:0] test_p;
        begin
            // Calculate expected result using signed multiplication
            expected = $signed(test_a) * $signed(test_b);
            
            #1; // Small delay for signal propagation
            
            if (test_p !== expected) begin
                $display("ERROR at time %0t: a=%b (%0d), b=%b (%0d), p=%b (%0d), expected=%b (%0d)",
                         $time, test_a, to_signed_4bit(test_a), 
                         test_b, to_signed_4bit(test_b),
                         test_p, to_signed_8bit(test_p),
                         expected, to_signed_8bit(expected));
                errors = errors + 1;
            end else begin
                $display("PASS: a=%b (%0d) * b=%b (%0d) = p=%b (%0d)",
                         test_a, to_signed_4bit(test_a),
                         test_b, to_signed_4bit(test_b),
                         test_p, to_signed_8bit(test_p));
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        // Initialize
        a = 0;
        b = 0;
        errors = 0;
        test_count = 0;
        
        $display("========================================");
        $display("Baugh-Wooley 4x4 Multiplier Testbench");
        $display("Testing Two's Complement Multiplication");
        $display("========================================");
        
        #10;
        
        // Test 1: Zero multiplication
        $display("\n--- Test Group 1: Zero Multiplication ---");
        a = 4'b0000; b = 4'b0000; #10; check_result(a, b, p);
        a = 4'b0000; b = 4'b0101; #10; check_result(a, b, p);
        a = 4'b0101; b = 4'b0000; #10; check_result(a, b, p);
        
        // Test 2: Positive * Positive
        $display("\n--- Test Group 2: Positive * Positive ---");
        a = 4'b0001; b = 4'b0001; #10; check_result(a, b, p); // 1 * 1 = 1
        a = 4'b0010; b = 4'b0010; #10; check_result(a, b, p); // 2 * 2 = 4
        a = 4'b0011; b = 4'b0011; #10; check_result(a, b, p); // 3 * 3 = 9
        a = 4'b0100; b = 4'b0100; #10; check_result(a, b, p); // 4 * 4 = 16
        a = 4'b0111; b = 4'b0111; #10; check_result(a, b, p); // 7 * 7 = 49
        a = 4'b0010; b = 4'b0101; #10; check_result(a, b, p); // 2 * 5 = 10
        a = 4'b0110; b = 4'b0011; #10; check_result(a, b, p); // 6 * 3 = 18
        
        // Test 3: Negative * Positive
        $display("\n--- Test Group 3: Negative * Positive ---");
        a = 4'b1111; b = 4'b0001; #10; check_result(a, b, p); // -1 * 1 = -1
        a = 4'b1110; b = 4'b0010; #10; check_result(a, b, p); // -2 * 2 = -4
        a = 4'b1101; b = 4'b0011; #10; check_result(a, b, p); // -3 * 3 = -9
        a = 4'b1100; b = 4'b0100; #10; check_result(a, b, p); // -4 * 4 = -16
        a = 4'b1000; b = 4'b0111; #10; check_result(a, b, p); // -8 * 7 = -56
        a = 4'b1010; b = 4'b0101; #10; check_result(a, b, p); // -6 * 5 = -30
        
        // Test 4: Positive * Negative
        $display("\n--- Test Group 4: Positive * Negative ---");
        a = 4'b0001; b = 4'b1111; #10; check_result(a, b, p); // 1 * -1 = -1
        a = 4'b0010; b = 4'b1110; #10; check_result(a, b, p); // 2 * -2 = -4
        a = 4'b0011; b = 4'b1101; #10; check_result(a, b, p); // 3 * -3 = -9
        a = 4'b0100; b = 4'b1100; #10; check_result(a, b, p); // 4 * -4 = -16
        a = 4'b0111; b = 4'b1000; #10; check_result(a, b, p); // 7 * -8 = -56
        a = 4'b0101; b = 4'b1010; #10; check_result(a, b, p); // 5 * -6 = -30
        
        // Test 5: Negative * Negative
        $display("\n--- Test Group 5: Negative * Negative ---");
        a = 4'b1111; b = 4'b1111; #10; check_result(a, b, p); // -1 * -1 = 1
        a = 4'b1110; b = 4'b1110; #10; check_result(a, b, p); // -2 * -2 = 4
        a = 4'b1101; b = 4'b1101; #10; check_result(a, b, p); // -3 * -3 = 9
        a = 4'b1100; b = 4'b1100; #10; check_result(a, b, p); // -4 * -4 = 16
        a = 4'b1000; b = 4'b1000; #10; check_result(a, b, p); // -8 * -8 = 64
        a = 4'b1010; b = 4'b1011; #10; check_result(a, b, p); // -6 * -5 = 30
        
        // Test 6: Edge cases
        $display("\n--- Test Group 6: Edge Cases ---");
        a = 4'b0111; b = 4'b1000; #10; check_result(a, b, p); // 7 * -8 = -56 (max positive * min negative)
        a = 4'b1000; b = 4'b0111; #10; check_result(a, b, p); // -8 * 7 = -56 (min negative * max positive)
        a = 4'b1000; b = 4'b1111; #10; check_result(a, b, p); // -8 * -1 = 8
        a = 4'b0111; b = 4'b0001; #10; check_result(a, b, p); // 7 * 1 = 7
        
        // Test 7: Comprehensive corner cases
        $display("\n--- Test Group 7: Additional Corner Cases ---");
        a = 4'b1111; b = 4'b1000; #10; check_result(a, b, p); // -1 * -8 = 8
        a = 4'b1000; b = 4'b1001; #10; check_result(a, b, p); // -8 * -7 = 56
        a = 4'b0110; b = 4'b1010; #10; check_result(a, b, p); // 6 * -6 = -36
        a = 4'b1011; b = 4'b0110; #10; check_result(a, b, p); // -5 * 6 = -30
        
        // Summary
        #10;
        $display("\n========================================");
        $display("Test Summary:");
        $display("Total Tests: %0d", test_count);
        $display("Errors: %0d", errors);
        if (errors == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        $display("========================================");
        
        #10;
        $finish;
    end
    
    // Monitor for waveform viewing
    initial begin
        $dumpfile("baugh_wooley_4x4.vcd");
        $dumpvars(0, baugh_wooley_4x4_tb);
    end

endmodule
