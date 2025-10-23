# ⚽ ScoutAI - AI-Powered Football Scouting Platform

> Discover hidden gems in football with advanced analytics and machine learning

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java](https://img.shields.io/badge/Java-17+-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-17+-red.svg)](https://angular.io/)
[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)

## 🎯 Project Overview

ScoutAI is a comprehensive football scouting platform that leverages advanced analytics and machine learning to help scouts, analysts, and clubs discover undervalued talent across global leagues.

### Key Features

- 🔍 **Intelligent Search**: Natural language queries like "press-resistant defensive midfielder with excellent passing"
- 📊 **Advanced Analytics**: Detailed performance metrics including xG, progressive passes, pressure statistics
- 📈 **Trend Analysis**: Track player development across matchdays and seasons
- 🎯 **Player Similarity**: Find players with similar playing styles using ML algorithms
- 💰 **Market Value Tracking**: Monitor player valuations and identify investment opportunities
- 📋 **Watchlists**: Create and manage custom player lists
- ⚖️ **Player Comparison**: Side-by-side comparison with radar charts and detailed metrics

### League Coverage

**Premium Stats (20+ leagues with advanced metrics):**
- 🇩🇪 Bundesliga, 2. Bundesliga
- 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League, Championship
- 🇪🇸 La Liga, La Liga 2
- 🇮🇹 Serie A, Serie B
- 🇫🇷 Ligue 1, Ligue 2
- 🇳🇱 Eredivisie
- 🇵🇹 Liga Portugal
- 🇧🇷 Brasileirão
- 🇺🇸 MLS
- 🏆 UEFA Champions League, Europa League, Conference League

## 🏗️ Architecture

### Tech Stack

**Backend** (Spring Boot 3.x)
- Java 17+
- Spring Data JPA
- Spring Security (JWT)
- PostgreSQL
- Redis (Caching)
- Maven

**ML Service** (Python 3.11)
- FastAPI
- Sentence Transformers
- scikit-learn
- pandas
- BeautifulSoup4 (Web Scraping)

**Frontend** (Angular 17)
- TypeScript
- RxJS
- Chart.js / D3.js
- Tailwind CSS

**Infrastructure**
- Docker & Docker Compose
- GitHub Actions (CI/CD)
- PostgreSQL 15
- Redis 7

## 🚀 Getting Started

### Prerequisites

- **Java JDK 17+** ([Download](https://adoptium.net/))
- **Node.js 18+** ([Download](https://nodejs.org/))
- **Python 3.11+** ([Download](https://www.python.org/))
- **Docker Desktop** ([Download](https://www.docker.com/products/docker-desktop/))
- **Maven 3.8+**
- **Git**

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/codemassel/scoutai.git
cd scoutai
```

2. **Setup environment variables**
```bash
# Copy the example env file
cp .env.example .env

# Edit .env with your credentials (NEVER commit this file!)
# Use a text editor to set secure passwords
```

3. **Start infrastructure services**
```bash
docker-compose up -d
```

3. **Backend Setup**
```bash
cd backend
./mvnw clean install
./mvnw spring-boot:run
```

4. **ML Service Setup**
```bash
cd ml-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

5. **Frontend Setup**
```bash
cd frontend
npm install
ng serve
```

6. **Access the application**
- Frontend: http://localhost:4200
- Backend API: http://localhost:8080
- ML Service: http://localhost:8000
- API Documentation: http://localhost:8080/swagger-ui.html

## 📊 Database Schema

The database follows **3rd Normal Form** principles with matchday-level granularity for detailed player statistics.

Key entities:
- `players` - Player profiles and basic information
- `player_matchday_stats` - Detailed performance metrics per matchday
- `player_season_stats` - Aggregated seasonal statistics
- `teams`, `leagues`, `seasons`, `matchdays` - Competition structure
- `users`, `watchlists` - User management

See [Database Documentation](./docs/database-schema.md) for detailed ER diagram.

## 🧪 Testing

### Backend Tests
```bash
cd backend
./mvnw test
./mvnw verify  # includes integration tests
```

### Frontend Tests
```bash
cd frontend
ng test
ng e2e
```

### ML Service Tests
```bash
cd ml-service
pytest
```

## 📈 Development Roadmap

### Phase 1: Foundation ✅
- [x] Database schema design
- [x] Project structure setup
- [ ] Docker configuration
- [ ] CI/CD pipeline

### Phase 2: Core Features (In Progress)
- [ ] Data scraping pipeline (FBref, Transfermarkt)
- [ ] REST API endpoints
- [ ] Basic player search and filtering
- [ ] Player detail views

### Phase 3: Advanced Features
- [ ] ML-powered natural language search
- [ ] Player similarity algorithm
- [ ] Advanced visualizations (radar charts, heatmaps)
- [ ] User authentication and watchlists

### Phase 4: Polish & Deploy
- [ ] Performance optimization
- [ ] Comprehensive documentation
- [ ] Production deployment
- [ ] Demo video

## 🤝 Contributing

This is a portfolio project currently in active development. Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Code Style

- **Java**: Google Java Style Guide
- **Python**: PEP 8
- **TypeScript**: Angular Style Guide
- **Commits**: Conventional Commits

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**CODEMASSEL**
- GitHub: [@codemassel](https://github.com/codemassel)

## 🙏 Acknowledgments

- Data sources: FBref, Transfermarkt
- Inspired by modern scouting methodologies
- Built with ❤️ for the football community

---

⭐ Star this repo if you find it useful!
