import HeroDashboard from '../components/hero_beranda';
import InformasiDashboard from '../components/informasi_beranda';
import InformasiInstansi from '../components/informasi_instansi';
import AgendaBeranda from '../components/agenda_beranda';

const DashboardPage = () => {
  return (
    <div className="relative">
      <div className="fixed inset-0 bg-new-gradient -z-10" />
        <HeroDashboard />
        <InformasiDashboard />
        <InformasiInstansi />
        <AgendaBeranda />
    </div>
  );
};

export default DashboardPage;
