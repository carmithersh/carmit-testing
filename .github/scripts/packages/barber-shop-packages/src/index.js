/**
 * Barbershop Tools - A minimal collection of utility functions for barbershop management
 */

// Service pricing utilities
const servicePrices = {
  'haircut': 25,
  'beard-trim': 15,
  'haircut-beard': 35,
  'kids-haircut': 18,
  'senior-haircut': 20
};

/**
 * Calculate service price with optional discount
 * @param {string} service - Service type
 * @param {number} discount - Discount percentage (0-100)
 * @returns {number} Final price
 */
function calculatePrice(service, discount = 0) {
  const basePrice = servicePrices[service] || 0;
  const discountAmount = (basePrice * discount) / 100;
  return Math.round((basePrice - discountAmount) * 100) / 100;
}

/**
 * Generate a service slip
 * @param {string} customerName - Customer name
 * @param {string} service - Service type
 * @param {number} discount - Discount percentage (0-100)
 * @returns {string} Formatted service slip
 */
function generateSlip(customerName, service, discount = 0) {
  const price = calculatePrice(service, discount);
  const date = new Date().toLocaleDateString();
  const time = new Date().toLocaleTimeString();
  
  return `
=== BARBERSHOP SERVICE SLIP ===
Date: ${date}
Time: ${time}
Customer: ${customerName}
Service: ${service}
${discount > 0 ? `Discount: ${discount}%` : ''}
Price: $${price.toFixed(2)}
===============================
  `.trim();
}

// Export functions
module.exports = {
  calculatePrice,
  generateSlip,
  servicePrices
};
