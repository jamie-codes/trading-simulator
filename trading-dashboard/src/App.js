import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Line } from 'react-chartjs-2';

function App() {
  const [trades, setTrades] = useState([]);
  const [metrics, setMetrics] = useState({});

  useEffect(() => {
    // Fetch trades from the trading application
    // TODO: add urls below
    axios.get('http://<trading-app-url>/trades')
      .then(response => setTrades(response.data))
      .catch(error => console.error(error));

    // Fetch metrics from Prometheus
    axios.get('http://<prometheus-url>/api/v1/query?query=trades_total')
      .then(response => setMetrics(response.data))
      .catch(error => console.error(error));
  }, []);

  const chartData = {
    labels: trades.map(trade => trade.timestamp),
    datasets: [
      {
        label: 'Trade Price',
        data: trades.map(trade => trade.price),
        borderColor: 'rgba(75, 192, 192, 1)',
        fill: false,
      },
    ],
  };

  return (
    <div className="App">
      <h1>Trading Dashboard</h1>

      <h2>Trade Activity</h2>
      <Line data={chartData} />

      <h2>Metrics</h2>
      <pre>{JSON.stringify(metrics, null, 2)}</pre>

      <h2>Logs</h2>
      <iframe
        src="http://<kibana-url>/app/discover"
        title="Kibana Logs"
        width="100%"
        height="500px"
      />
    </div>
  );
}

export default App;