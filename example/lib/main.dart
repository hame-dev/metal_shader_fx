import 'package:flutter/material.dart';
import 'package:metal_shader_fx/metal_shader_fx.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F7),
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool _enabled = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Toggle with gold accent ──
                  MetalToggleCard(
                    value: _enabled,
                    accentColor: const Color(0xFFE3AA00),
                    onChanged: (v) => setState(() => _enabled = v),
                    enabledLabel: 'Active',
                    disabledLabel: 'Inactive',
                    material: const MetalMaterialConfig.gold(),
                  ),

                  const SizedBox(height: 28),

                  // ── Button with gunmetal accent, chrome material ──
                  MetallicBorderButton(
                    text: 'Continue',
                    color: const Color(0xFF141334),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Button pressed!')),
                      );
                    },
                    material: const MetalMaterialConfig.chrome(),
                  ),

                  const SizedBox(height: 20),

                  // ── Button with custom child ──
                  MetallicBorderButton(
                    color: const Color(0xFFEDF7FC),
                    onPressed: () {},
                    height: 56,
                    borderRadius: 16,
                    material: const MetalMaterialConfig(
                      roughness: 0.10,
                      filmThickness: 0.5,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Send Message',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Disabled button ──
                  MetallicBorderButton(
                    text: 'Disabled',
                    color: Colors.grey,
                    enabled: false,
                    onPressed: () {},
                  ),

                  const SizedBox(height: 28),

                  // ── Email field with gold accent ──
                  MetallicBorderTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    color: const Color(0xFFE3AA00),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => debugPrint('Email: $v'),
                    material: const MetalMaterialConfig.anodized(),
                  ),

                  const SizedBox(height: 16),

                  // ── Password field with prefix/suffix icons ──
                  MetallicBorderTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    color: const Color(0xFF55267E),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) => debugPrint('Password submitted'),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: const Icon(Icons.visibility_off_outlined, size: 20),
                    material: const MetalMaterialConfig.brushedSteel(),
                  ),

                  const SizedBox(height: 16),

                  // ── Multi-line field ──
                  MetallicBorderTextField(
                    hintText: 'Write a message...',
                    color: const Color(0xFF1A73E8),
                    maxLines: 4,
                    height: 120,
                    onChanged: (v) => debugPrint('Message: $v'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
