package com.godot.game;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.HashSet;
import java.util.Set;

/**
 * Native Google AdMob GodotPlugin for Zen Mahjong.
 * Supports Banner, Interstitial, and Rewarded Video Ads.
 */
public class AdMobPlugin extends GodotPlugin {
	private static final String TAG = "AdMobPlugin";

	private boolean isInitialized = false;

	// Banner
	private AdView adView;
	private FrameLayout bannerLayout;
	private boolean bannerOnTop = false;

	// Interstitial
	private InterstitialAd interstitialAd;
	private boolean isInterstitialLoading = false;

	// Rewarded
	private RewardedAd rewardedAd;
	private boolean isRewardedLoading = false;

	public AdMobPlugin(Godot godot) {
		super(godot);
	}

	@NonNull
	@Override
	public String getPluginName() {
		return "AdMobPlugin";
	}

	@NonNull
	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new HashSet<>();
		signals.add(new SignalInfo("initialization_complete"));

		// Banner signals
		signals.add(new SignalInfo("banner_loaded"));
		signals.add(new SignalInfo("banner_failed_to_load", Integer.class));

		// Interstitial signals
		signals.add(new SignalInfo("interstitial_loaded"));
		signals.add(new SignalInfo("interstitial_failed_to_load", Integer.class));
		signals.add(new SignalInfo("interstitial_dismissed"));

		// Rewarded signals
		signals.add(new SignalInfo("rewarded_loaded"));
		signals.add(new SignalInfo("rewarded_failed_to_load", Integer.class));
		signals.add(new SignalInfo("rewarded_user_earned_reward", String.class, Integer.class));
		signals.add(new SignalInfo("rewarded_dismissed"));

		return signals;
	}

	@UsedByGodot
	public void initialize() {
		final Activity activity = getActivity();
		if (activity == null) {
			Log.e(TAG, "Activity is null, cannot initialize AdMob");
			return;
		}

		activity.runOnUiThread(() -> {
			if (isInitialized) {
				emitSignal("initialization_complete");
				return;
			}
			MobileAds.initialize(activity, initializationStatus -> {
				Log.i(TAG, "Google Mobile Ads SDK Initialized successfully");
				isInitialized = true;
				emitSignal("initialization_complete");
			});
		});
	}

	/* ====================================================================== */
	/*                             BANNER ADS                                 */
	/* ====================================================================== */

	@UsedByGodot
	public void loadBanner(final String adUnitId, final boolean isOnTop) {
		final Activity activity = getActivity();
		if (activity == null) return;

		this.bannerOnTop = isOnTop;

		activity.runOnUiThread(() -> {
			try {
				if (adView != null) {
					destroyBanner();
				}

				adView = new AdView(activity);
				adView.setAdUnitId(adUnitId);
				adView.setAdSize(AdSize.BANNER);

				adView.setAdListener(new AdListener() {
					@Override
					public void onAdLoaded() {
						Log.i(TAG, "Banner ad loaded");
						emitSignal("banner_loaded");
					}

					@Override
					public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
						Log.w(TAG, "Banner ad failed to load: " + loadAdError.getMessage());
						emitSignal("banner_failed_to_load", loadAdError.getCode());
					}
				});

				bannerLayout = new FrameLayout(activity);
				FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
						ViewGroup.LayoutParams.MATCH_PARENT,
						ViewGroup.LayoutParams.WRAP_CONTENT
				);
				layoutParams.gravity = isOnTop ? Gravity.TOP | Gravity.CENTER_HORIZONTAL : Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
				bannerLayout.setLayoutParams(layoutParams);

				FrameLayout.LayoutParams adParams = new FrameLayout.LayoutParams(
						ViewGroup.LayoutParams.WRAP_CONTENT,
						ViewGroup.LayoutParams.WRAP_CONTENT
				);
				adParams.gravity = Gravity.CENTER_HORIZONTAL;
				adView.setLayoutParams(adParams);

				bannerLayout.addView(adView);

				ViewGroup root = activity.findViewById(android.R.id.content);
				if (root != null) {
					root.addView(bannerLayout);
				}

				AdRequest adRequest = new AdRequest.Builder().build();
				adView.loadAd(adRequest);

			} catch (Exception e) {
				Log.e(TAG, "Exception loading banner", e);
			}
		});
	}

	@UsedByGodot
	public void showBanner() {
		final Activity activity = getActivity();
		if (activity == null) return;

		activity.runOnUiThread(() -> {
			if (bannerLayout != null) {
				bannerLayout.setVisibility(View.VISIBLE);
			}
		});
	}

	@UsedByGodot
	public void hideBanner() {
		final Activity activity = getActivity();
		if (activity == null) return;

		activity.runOnUiThread(() -> {
			if (bannerLayout != null) {
				bannerLayout.setVisibility(View.GONE);
			}
		});
	}

	@UsedByGodot
	public void destroyBanner() {
		final Activity activity = getActivity();
		if (activity == null) return;

		activity.runOnUiThread(() -> {
			if (adView != null) {
				adView.destroy();
				adView = null;
			}
			if (bannerLayout != null) {
				ViewGroup root = activity.findViewById(android.R.id.content);
				if (root != null) {
					root.removeView(bannerLayout);
				}
				bannerLayout = null;
			}
		});
	}

	/* ====================================================================== */
	/*                          INTERSTITIAL ADS                              */
	/* ====================================================================== */

	@UsedByGodot
	public void loadInterstitial(final String adUnitId) {
		final Activity activity = getActivity();
		if (activity == null || isInterstitialLoading) return;

		activity.runOnUiThread(() -> {
			isInterstitialLoading = true;
			AdRequest adRequest = new AdRequest.Builder().build();

			InterstitialAd.load(activity, adUnitId, adRequest, new InterstitialAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull InterstitialAd ad) {
					interstitialAd = ad;
					isInterstitialLoading = false;
					Log.i(TAG, "Interstitial ad loaded");
					emitSignal("interstitial_loaded");

					interstitialAd.setFullScreenContentCallback(new FullScreenContentCallback() {
						@Override
						public void onAdDismissedFullScreenContent() {
							interstitialAd = null;
							Log.i(TAG, "Interstitial ad dismissed");
							emitSignal("interstitial_dismissed");
						}

						@Override
						public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
							interstitialAd = null;
							Log.w(TAG, "Interstitial failed to show: " + adError.getMessage());
							emitSignal("interstitial_dismissed");
						}
					});
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					interstitialAd = null;
					isInterstitialLoading = false;
					Log.w(TAG, "Interstitial ad failed to load: " + loadAdError.getMessage());
					emitSignal("interstitial_failed_to_load", loadAdError.getCode());
				}
			});
		});
	}

	@UsedByGodot
	public boolean isInterstitialLoaded() {
		return interstitialAd != null;
	}

	@UsedByGodot
	public void showInterstitial() {
		final Activity activity = getActivity();
		if (activity == null) return;

		activity.runOnUiThread(() -> {
			if (interstitialAd != null) {
				interstitialAd.show(activity);
			} else {
				Log.w(TAG, "Interstitial ad not ready to show");
				emitSignal("interstitial_dismissed");
			}
		});
	}

	/* ====================================================================== */
	/*                            REWARDED ADS                                */
	/* ====================================================================== */

	@UsedByGodot
	public void loadRewarded(final String adUnitId) {
		final Activity activity = getActivity();
		if (activity == null || isRewardedLoading) return;

		activity.runOnUiThread(() -> {
			isRewardedLoading = true;
			AdRequest adRequest = new AdRequest.Builder().build();

			RewardedAd.load(activity, adUnitId, adRequest, new RewardedAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull RewardedAd ad) {
					rewardedAd = ad;
					isRewardedLoading = false;
					Log.i(TAG, "Rewarded ad loaded");
					emitSignal("rewarded_loaded");

					rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
						@Override
						public void onAdDismissedFullScreenContent() {
							rewardedAd = null;
							Log.i(TAG, "Rewarded ad dismissed");
							emitSignal("rewarded_dismissed");
						}

						@Override
						public void onAdFailedToShowFullScreenContent(@NonNull AdError adError) {
							rewardedAd = null;
							Log.w(TAG, "Rewarded ad failed to show: " + adError.getMessage());
							emitSignal("rewarded_dismissed");
						}
					});
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					rewardedAd = null;
					isRewardedLoading = false;
					Log.w(TAG, "Rewarded ad failed to load: " + loadAdError.getMessage());
					emitSignal("rewarded_failed_to_load", loadAdError.getCode());
				}
			});
		});
	}

	@UsedByGodot
	public boolean isRewardedLoaded() {
		return rewardedAd != null;
	}

	@UsedByGodot
	public void showRewarded() {
		final Activity activity = getActivity();
		if (activity == null) return;

		activity.runOnUiThread(() -> {
			if (rewardedAd != null) {
				rewardedAd.show(activity, new OnUserEarnedRewardListener() {
					@Override
					public void onUserEarnedReward(@NonNull RewardItem rewardItem) {
						String type = rewardItem.getType();
						int amount = rewardItem.getAmount();
						Log.i(TAG, "User earned reward: " + amount + " " + type);
						emitSignal("rewarded_user_earned_reward", type, amount);
					}
				});
			} else {
				Log.w(TAG, "Rewarded ad not ready to show");
				emitSignal("rewarded_dismissed");
			}
		});
	}

	@Override
	public void onMainDestroy() {
		destroyBanner();
		super.onMainDestroy();
	}
}
