using Uno;
using Uno.Testing;
using Uno.UX;

using Fuse.Controls;

using FuseTest;

namespace Fuse.Test
{
	public class RootingTest : TestBase
	{
		[Test]
		public void Ordering()
		{
			var p = new UX.RootingOrdering();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.Children.Remove(p.P1);
				p.Children.Add(p.P1);

				p.W2.Value = false;
				p.W2.Value = true;
			}
		}

		[Test]
		public void Paradox()
		{
			try
			{
				var p = new UX.RootingParadox();
				using (var root = TestRootPanel.CreateWithChild(p))
					Assert.IsTrue(false); // we shouldn't get here
			} catch( Exception ex ) {
				//just ensure we've detected a rooting problem
				Assert.IsTrue( ex.Message.IndexOf( "rooting" ) != -1 );
			}
		}

		[Test]
		[Ignore("https://github.com/fusetools/fuselibs/issues/2244")]
		public void UnrootDuringRoot()
		{
			var p = new UX.UnrootDuringRoot();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				Assert.IsFalse(p.B1.Value);
				Assert.IsFalse(p.Children.Contains(p.P2));
				Assert.IsFalse(p.P2.IsRootingCompleted);
			}
		}

		[Test]
		/** This is a variant that we actually supported when these tests were first written. */
		public void UnrootVariant()
		{
			var p = new UX.UnrootVariant();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				root.IncrementFrame();

				p.B2.Value = true;
				root.PumpDeferred();
				Assert.IsFalse(p.B1.Value);
				Assert.IsFalse(p.Children.Contains(p.P2));
				Assert.IsFalse(p.P2.IsRootingCompleted);

				root.IncrementFrame();
				//B2 is not true, so it will skip the action during rooting
				p.B1.Value = true;
				Assert.IsTrue(p.B1.Value);
				Assert.IsTrue(p.Children.Contains(p.P2));
				Assert.IsTrue(p.P2.IsRootingCompleted);
			}
		}
		
		//https://github.com/fusetools/fuselibs-public/issues/430
		[Test]
		public void DoubleRooting()
		{
			var p = new UX.Rooting.DoubleRooting();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				Assert.AreEqual( "okay", GetText(p.rov));
			}
		}
	}
	
	/*
		This mimics a behavior that `PageControl.Pages` and `AlternateRoot` could exhibit. Those might change thus as not being relied upon to test the rooting guarantee. This new class tests a specific scenario where those classes failed.
		
		Refer to https://github.com/fusetools/fuselibs-public/issues/430
	*/
	public class RootOrderVisual : Panel
	{
		Text _p;
		
		//bindings resolve prior to OnRooted, but during rooting, this simulates that
		protected override void OnRootedPreChildren()
		{
			base.OnRootedPreChildren();
			
			_p = new Text();
			_p.Value = "okay";
			Children.Add(_p);
		}
		
		protected override void OnUnrooted()
		{
			base.OnUnrooted();
			Children.Remove(_p);
			_p = null;
		}
	}
}
