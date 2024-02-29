const stripe = require('stripe')('pk_test_51Oc9WPHDirRzPkGPs7RVgxaLXz7ZEpmeULsvZQsk5xDhtFPST7ke5TDCH03H444ijUW5xFcIt5R6YUSLEctCxlzG00ASdfAHZx'); // Reemplaza con tu clave secreta de Stripe

// Función para generar el token
async function generateToken(cardNumber, expMonth, expYear, cvc) {
  try {
    const token = await stripe.tokens.create({
      card: {
        number: cardNumber,
        exp_month: expMonth,
        exp_year: expYear,
        cvc: cvc
      }
    });
    return token.id;
  } catch (error) {
    throw error;
  }
}

// Leer datos de la línea de comandos
const args = process.argv.slice(2);
const cardNumber = args[0];
const expMonth = args[1];
const expYear = args[2];
const cvc = args[3];

// Generar el token y mostrarlo en la consola
generateToken(cardNumber, expMonth, expYear, cvc)
  .then(token => console.log(token))
  .catch(error => console.error(error));
