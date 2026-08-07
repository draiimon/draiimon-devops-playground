'use client';
import React, { useState, useEffect } from 'react';

const DataTab = () => {
  const [data, setData] = useState(null);

  useEffect(() => {
    // Fetch data from the URL
    // fetch('http://localhost:8000/trip?limit=10&sort=latest')
    fetch(`${process.env.NEXT_PUBLIC_API_URL}/trip?limit=10&sort=latest`)
      .then(response => response.json())
      .then(data => setData(data))
      .catch(error => console.log(error));
      console.log(process.env.NEXT_PUBLIC_API_URL)
  }, []);

  return (
    <div>
      <h2>Data Tab</h2>
      {data ? (
        <ul>
          {data.map(item => (
            <li key={item.idx}> {item.name} - {item.description}</li>
          ))}
        </ul>
      ) : (
        <p>Loading data...</p>
      )}
    </div>
  );
};

export default DataTab;