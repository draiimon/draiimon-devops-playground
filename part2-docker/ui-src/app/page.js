import Head from 'next/head';
import DataTab from '../components/DataTab';

const Home = () => {
  return (
    <div>
      <Head>
        <title>Next.js Data Tab</title>
        <meta name="description" content="Next.js app that fetches and displays data" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main>
        <h1>Next.js Data App</h1>
        <DataTab />
      </main>

      <footer>
        <p>Footer content here</p>
      </footer>
    </div>
  );
};

export default Home;