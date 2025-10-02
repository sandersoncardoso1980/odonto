import 'package:flutter/material.dart';
import 'package:odonto/widgets/header/desktop_header.dart';
import 'package:odonto/widgets/header/mobile_header.dart';
//import '/widgets/header/header.dart';
import '/widgets/hero/hero_section.dart';
import '/widgets/sections/specialties_section.dart';
import '/widgets/sections/advantages_section.dart';
import '/widgets/sections/testimonials_section.dart';
import '/widgets/sections/faq_section.dart';
import '/widgets/sections/stats_section.dart';
import '/widgets/sections/process_section.dart';
import '/widgets/sections/newsletter_section.dart';
import '/widgets/sections/cta_section.dart';
import '/widgets/footer/footer.dart';

class LandingPage extends StatefulWidget {
  final String? scrollToSection;

  const LandingPage({super.key, this.scrollToSection});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'inicio': GlobalKey(),
    'processo': GlobalKey(),
    'servicos': GlobalKey(),
    'especialidades': GlobalKey(),
    'vantagens': GlobalKey(),
    'sobre': GlobalKey(),
    'depoimentos': GlobalKey(),
    'faq': GlobalKey(),
    'contato': GlobalKey(),
  };

  bool _isHeaderVisible = true;
  bool _isScrolled = false;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSection();
    });
  }

  void _handleScroll() {
    final currentOffset = _scrollController.offset;

    // Mostrar/ocultar header baseado na direção do scroll
    if (currentOffset > 100 && currentOffset > _lastScrollOffset) {
      // Scroll para baixo - esconder header
      if (_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = false;
          _isScrolled = currentOffset > 50;
        });
      }
    } else if (currentOffset < _lastScrollOffset) {
      // Scroll para cima - mostrar header
      if (!_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
          _isScrolled = currentOffset > 50;
        });
      }
    }

    _lastScrollOffset = currentOffset;
  }

  void _scrollToSection() {
    if (widget.scrollToSection != null &&
        _sectionKeys.containsKey(widget.scrollToSection)) {
      final key = _sectionKeys[widget.scrollToSection]!;
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }
  }

  @override
  void didUpdateWidget(LandingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToSection != oldWidget.scrollToSection) {
      _scrollToSection();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final isSmallMobile = constraints.maxWidth < 400;

            return Stack(
              children: [
                // Conteúdo principal
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Espaço para o header fixo (para evitar sobreposição)
                      SizedBox(height: isMobile ? 80 : 100),

                      // HERO SECTION
                      HeroSection(
                        isMobile: isMobile,
                        isSmallMobile: isSmallMobile,
                        context: context,
                      ),

                      // STATS SECTION
                      StatsSection(isMobile: isMobile),

                      // HOW IT WORKS SECTION
                      ProcessSection(isMobile: isMobile),

                      // SPECIALTIES SECTION (Serviços)
                      SpecialtiesSection(
                        isMobile: isMobile,
                        sectionKey: _sectionKeys['especialidades']!,
                      ),

                      // ADVANTAGES SECTION (Sobre/Profissionais)
                      AdvantagesSection(
                        isMobile: isMobile,
                        sectionKey: _sectionKeys['vantagens']!,
                      ),

                      // TESTIMONIALS SECTION
                      TestimonialsSection(
                        isMobile: isMobile,
                        sectionKey: _sectionKeys['depoimentos']!,
                      ),

                      // FAQ SECTION
                      FAQSection(
                        isMobile: isMobile,
                        sectionKey: _sectionKeys['faq']!,
                      ),

                      // NEWSLETTER SECTION
                      NewsletterSection(
                        isMobile: isMobile,
                        isSmallMobile: isSmallMobile,
                        context: context,
                      ),

                      // CTA SECTION
                      CTASection(
                        isMobile: isMobile,
                        isSmallMobile: isSmallMobile,
                        context: context,
                      ),

                      // FOOTER SECTION (Contato)
                      Footer(
                        isMobile: isMobile,
                        context: context,
                        sectionKey: _sectionKeys['contato']!,
                        configuracoes: {},
                      ),
                    ],
                  ),
                ),

                // Header flutuante
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: _isHeaderVisible ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: _FloatingHeader(
                    isMobile: isMobile,
                    isSmallMobile: isSmallMobile,
                    context: context,
                    sectionKey: _sectionKeys['inicio']!,
                    isScrolled: _isScrolled,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloatingHeader extends StatelessWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final BuildContext context;
  final GlobalKey sectionKey;
  final bool isScrolled;

  const _FloatingHeader({
    required this.isMobile,
    required this.isSmallMobile,
    required this.context,
    required this.sectionKey,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isScrolled ? 4 : 0,
      color: Colors.white,
      child: Container(
        key: sectionKey,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile
              ? 12
              : isMobile
              ? 16
              : 24,
          vertical: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: isScrolled
              ? Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                )
              : null,
        ),
        child: isMobile
            ? MobileHeader(isSmallMobile: isSmallMobile, context: context)
            : DesktopHeader(context: context),
      ),
    );
  }
}
