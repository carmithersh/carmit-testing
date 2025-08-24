const { calculatePrice, generateSlip, servicePrices } = require('../src/index');

// Simple test function
function runTests() {
  // Test calculatePrice function
  const haircutPrice = calculatePrice('haircut');
  const haircutWithDiscount = calculatePrice('haircut', 10);
  const beardTrimPrice = calculatePrice('beard-trim');
  const invalidService = calculatePrice('invalid-service');
  
  // Test generateSlip function
  const slip = generateSlip('John Doe', 'haircut', 10);
  
  // Test servicePrices object
  const availableServices = Object.keys(servicePrices);
  
  // Verify expected results
  const tests = [
    { name: 'Haircut price', result: haircutPrice, expected: 25 },
    { name: 'Haircut with 10% discount', result: haircutWithDiscount, expected: 22.5 },
    { name: 'Beard trim price', result: beardTrimPrice, expected: 15 },
    { name: 'Invalid service', result: invalidService, expected: 0 }
  ];
  
  let allPassed = true;
  tests.forEach(test => {
    if (test.result !== test.expected) {
      console.error(`❌ ${test.name}: expected ${test.expected}, got ${test.result}`);
      allPassed = false;
    } else {
      console.log(`✅ ${test.name}: ${test.result}`);
    }
  });
  
  if (allPassed) {
    console.log('✅ All tests passed!');
  } else {
    console.error('❌ Some tests failed!');
    process.exit(1);
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests();
}

module.exports = { runTests };
