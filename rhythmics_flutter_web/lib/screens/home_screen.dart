import 'package:flutter/material.dart';
import 'package:rhythmics_flutter_web/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _futureStudios;

  @override
  void initState() {
    super.initState();
    _futureStudios = AuthService.fetchStudios(token: widget.token);
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) return 240;
    if (screenWidth > 800) return 120;
    if (screenWidth > 600) return 60;
    return 24;
  }

  double _getResponsiveFontSize(double baseSize, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return baseSize;
    if (screenWidth > 800) return baseSize * 0.9;
    if (screenWidth > 600) return baseSize * 0.8;
    return baseSize * 0.7;
  }

  String _getStudioImage(Map<String, dynamic> studio) {
    if (studio.containsKey('image_url') &&
        studio['image_url'] != null &&
        (studio['image_url'] as String).isNotEmpty) {
      return 'http://localhost:8080${studio['image_url']}';
    }
    return 'https://via.placeholder.com/400x300?text=Studio';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final horizontalPadding =
        isMobile ? 16.0 : _getHorizontalPadding(width);

    int crossAxisCount;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Homepage Penyewa Studio',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(20, context),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // === Studio Section ===
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 40,
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  Text(
                    'STUDIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          _getResponsiveFontSize(32, context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your music deserves the best—find studios near you today.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFB17457)),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<dynamic>>(
                    future: _futureStudios,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada studio yang tersedia.',
                            style:
                                TextStyle(fontSize: 16),
                          ),
                        );
                      }
                      final studios = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB17457),
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical:
                              isMobile ? 40 : 80,
                          horizontal: isMobile
                              ? 16
                              : horizontalPadding,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: studios.length,
                          itemBuilder: (context, index) {
                            final studio = studios[index]
                                as Map<String, dynamic>;
                            final imageUrl =
                                _getStudioImage(studio);
                            final name = (studio['name'] ??
                                    'Unnamed')
                                as String;
                            return _HoverScaleCard(
                              imageUrl: imageUrl,
                              label: name.toUpperCase(),
                              onTap: () =>
                                  Navigator.pushNamed(
                                context,
                                '/studio-detail',
                                arguments: {
                                  'token': widget.token,
                                  'studio': studio,
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // === About Section ===
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 80,
                horizontal: horizontalPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mobileLayout =
                      constraints.maxWidth < 768;
                  return Flex(
                    direction: mobileLayout
                        ? Axis.vertical
                        : Axis.horizontal,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: mobileLayout
                            ? double.infinity
                            : constraints.maxWidth * 0.4,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4'
                            '?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8'
                            'fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: mobileLayout ? 0 : 40,
                        height: mobileLayout ? 20 : 0,
                      ),
                      SizedBox(
                        width: mobileLayout
                            ? double.infinity
                            : constraints.maxWidth * 0.5,
                        child: Column(
                          crossAxisAlignment:
                              mobileLayout
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'About Us',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Rhythmics is your ultimate platform for discovering and booking the best music studios nearby, tailored to your creative needs. Whether you\'re recording your next hit, rehearsing with your band, or mixing tracks, we connect you with top-tier studios that provide everything you need to bring your sound to life. With real-time availability and a fast, secure booking process, finding the perfect space is effortless. Simply search for a studio, check its availability, and book with ease. Your next masterpiece is just a studio away!',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // === How It Works ===
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 0,
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  Text(
                    'How It Works',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          _getResponsiveFontSize(32, context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: isMobile ? 12 : 24),
                  _HowItWorksCard(
                    step: 1,
                    title: 'Find the Perfect Studio',
                    description:
                        'Browse through our curated list of studios tailored to your needs. Use our search tool to filter by location, equipment, and availability.',
                    icon: Icons.search,
                  ),
                  const SizedBox(height: 48),
                  _HowItWorksCard(
                    step: 2,
                    title: 'Check Availability',
                    description:
                        'View real-time availability and pick a time slot that fits your schedule. Never worry about double bookings!',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 48),
                  _HowItWorksCard(
                    step: 3,
                    title: 'Secure Your Booking',
                    description:
                        'Complete your reservation with our fast and secure booking process. Instant confirmation guaranteed.',
                    icon: Icons.lock,
                  ),
                  const SizedBox(height: 48),
                  _HowItWorksCard(
                    step: 4,
                    title: 'Bring Your Creativity to Life',
                    description:
                        'Step into your booked studio and focus on creating amazing music. Everything is ready for you to shine.',
                    icon: Icons.star,
                  ),
                ],
              ),
            ),

            // === Footer ===
            Container(
              width: double.infinity,
              color: const Color(0xFFB17457),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 40,
                horizontal: horizontalPadding,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        const Text(
                          'Rhythmics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your music studio booking platform',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [
                            _SocialIcon(icon: Icons.facebook, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.camera_alt, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.alternate_email, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.youtube_searched_for, url: '#'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          '© 2023 Rhythmics. All rights reserved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Rhythmics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your music studio booking platform',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            _SocialIcon(icon: Icons.facebook, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.camera_alt, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.alternate_email, url: '#'),
                            SizedBox(width: 16),
                            _SocialIcon(icon: Icons.youtube_searched_for, url: '#'),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverScaleCard extends StatefulWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const _HoverScaleCard({
    Key? key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.45),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatefulWidget {
  final int step;
  final String title;
  final String description;
  final IconData icon;

  const _HowItWorksCard({
    Key? key,
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  State<_HowItWorksCard> createState() => _HowItWorksCardState();
}

class _HowItWorksCardState extends State<_HowItWorksCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    const gradientStart = Color(0xFFB17457);
    const gradientEnd = Color(0xFFD8A583);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${widget.step}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({
    Key? key,
    required this.icon,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // tambahkan logika membuka URL jika perlu
        },
        child: Icon(
          icon,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
