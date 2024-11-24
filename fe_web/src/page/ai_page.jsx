// fe_web/src/page/ai_page.jsx
import React from 'react';


const AiPage = () => {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        {/* Header Section */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-800 mb-4">
            Gallery AI Assistant
          </h1>
          <p className="text-lg text-gray-600">
            Asisten pintar yang siap membantu Anda menjelajahi galeri foto kami
          </p>
        </div>

        {/* Features Section */}
        <div className="grid md:grid-cols-2 gap-8 mb-12">
          <FeatureCard
            title="Multi Bahasa"
            description="Berkomunikasi dalam Bahasa Indonesia dan English"
            icon={<LanguageIcon />}
          />
          <FeatureCard
            title="Cerdas & Kontekstual"
            description="Memberikan jawaban yang relevan sesuai konteks"
            icon={<BrainIcon />}
          />
          <FeatureCard
            title="Saran Pertanyaan"
            description="Memberikan saran pertanyaan yang relevan"
            icon={<SuggestIcon />}
          />
          <FeatureCard
            title="Riwayat Chat"
            description="Menyimpan riwayat percakapan Anda"
            icon={<HistoryIcon />}
          />
        </div>

        {/* Chat Demo Section */}
        <div className="bg-white rounded-lg shadow-xl p-6">
          <h2 className="text-2xl font-semibold text-gray-800 mb-4">
            Mulai Bertanya
          </h2>
          <p className="text-gray-600 mb-6">
            Klik tombol chat di pojok kanan bawah untuk mulai berbicara dengan AI Assistant
          </p>
          <div className="flex justify-center">
            <button
              onClick={() => {
                // Trigger floating chat button click
                document.querySelector('[data-testid="float-chat-btn"]')?.click();
              }}
              className="bg-blue-500 text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition-colors"
            >
              Mulai Chat
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// Feature Card Component
const FeatureCard = ({ title, description, icon }) => (
  <div className="bg-white rounded-lg shadow-md p-6">
    <div className="text-blue-500 mb-4">
      {icon}
    </div>
    <h3 className="text-xl font-semibold text-gray-800 mb-2">{title}</h3>
    <p className="text-gray-600">{description}</p>
  </div>
);

// Icons Components
const LanguageIcon = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129" />
  </svg>
);

const BrainIcon = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
  </svg>
);

const SuggestIcon = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
  </svg>
);

const HistoryIcon = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
  </svg>
);

export default AiPage;