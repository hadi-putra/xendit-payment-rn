import { useState, useEffect } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { XenditPayment } from 'xendit-payment-rn';

export default function App() {
  const [result, setResult] = useState<number | undefined>();

  useEffect(() => {
    const xendit = new XenditPayment();
    xendit.initialize('<public-key>');
    xendit.multiply(5, 7).then(setResult);
    xendit
      .createMultipleUseToken({
        cardNumber: '4000000000000002',
        cardExpMonth: '12',
        cardExpYear: '2025',
        cardHolder: {
          firstName: 'Test',
          lastName: 'Doe',
          email: 'testdoe@email.com',
        },
      })
      .then((resp) => console.log('single use token', resp))
      .catch((error) => console.error('sngle use token error', error));
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
